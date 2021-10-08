import AVFoundation
import UIKit
import ShazamKit
import Nuke

struct ShazamItem {
    let matchId: String
    let title: String
    let artist: String
    let artwork: URL?
}

class NoiseDetectorViewController: UIViewController {
    
    var timer: DispatchSourceTimer?
    let audioSession = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder?

    let audioEngine = AVAudioEngine()
    let mixerNode = AVAudioMixerNode()

    // The session for the active ShazamKit match request.
    var session = SHSession()
    var lastShazamItem: ShazamItem?
    
    var samples: [Float] = []
    
    @IBOutlet private var recordingImageView: UIImageView!
    @IBOutlet private var dbValueLabel: UILabel!
    @IBOutlet private var trackLabel: UILabel!
    @IBOutlet private var artistLabel: UILabel!
    @IBOutlet private var artworkView: UIImageView!
    @IBOutlet private var shazamContainer: UIView!
    @IBOutlet private var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        recordingImageView.setGIFImage(name: "recording")
        shazamContainer.alpha = 0.0
        shazamContainer.transform = CGAffineTransform(translationX: 150, y: 0)
        nextButton.layer.cornerRadius = 14
        nextButton.backgroundColor = .black
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.tintColor = .white
        
        configureAudioEngine()
        try? match()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioRecorder?.stop()
        stopListening()
        try? audioSession.setActive(false)
        audioRecorder = nil
        timer?.cancel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let claimVC = segue.destination as? NoiseClaimViewController else { return }
        claimVC.shazamItem = lastShazamItem
    }
    
    @IBAction private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
        return soundURL
    }
    
    func recordForever(audioRecorder: AVAudioRecorder) {
        let queue = DispatchQueue(label: "io.segment.decibel", attributes: .concurrent)
        timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        timer?.schedule(deadline: .now(), repeating: 0.4, leeway: .milliseconds(100))
        timer?.setEventHandler { [weak self] in
            audioRecorder.updateMeters()
            let average = audioRecorder.averagePower(forChannel: 0)
            let peak = audioRecorder.peakPower(forChannel: 0)
            self?.recordDatapoint(average: average, peak: peak)
        }
        timer?.resume()
    }
    
    private func recordDatapoint(average: Float, peak: Float) {
        let avgdB = dBFS_convertTo_dB(dBFSValue: average) * 100  /*average + 100*/
        let peakdB = dBFS_convertTo_dB(dBFSValue: peak) * 100 /*peak + 100*/

        print("avg: \(avgdB), peak: \(peakdB)")
        
        samples.append(peakdB)
        if samples.count > 12 {
            samples = Array(samples.dropFirst())
            
            DispatchQueue.main.async {
                let movingAverage = self.samples.reduce(0, { $0 + $1 }) / Float(self.samples.count)
                let rounded = Int(round(movingAverage))
                self.dbValueLabel.text = "\(rounded) дБ"
            }
        }
    }
    
    private func dBFS_convertTo_dB(dBFSValue: Float) -> Float {
        var level:Float = 0.0
        let peak_bottom:Float = -80.0 // dBFS -> -160..0   so it can be -80 or -60
        
        if dBFSValue < peak_bottom {
            level = 0.0
        } else if dBFSValue >= 0.0 {
            level = 1.0
        } else {
            let root:Float              =   2.0
            let minAmp:Float            =   powf(10.0, 0.05 * peak_bottom)
            let inverseAmpRange:Float   =   1.0 / (1.0 - minAmp)
            let amp:Float               =   powf(10.0, 0.05 * dBFSValue)
            let adjAmp:Float            =   (amp - minAmp) * inverseAmpRange
            
            level = powf(adjAmp, 1.0 / root)
        }
        return level
    }
    
    
    
    func match() throws {
        session.delegate = self
        // Start listening to the audio to find a match.
        try startListening()
    }
    
    func startListening() throws {
        // Throw an error if the audio engine is already running.
        guard !audioEngine.isRunning else { return }
        
        // Ask the user for permission to use the mic if required then start the engine.
        try audioSession.setCategory(.playAndRecord)
        audioSession.requestRecordPermission { [weak self] success in
            guard success, let self = self else { return }
            try? self.audioEngine.start()
            self.startRecording()
        }
    }
    
    func startRecording() {
        guard let url = directoryURL() else {
            print("Unable to find a init directoryURL")
            return
        }
        
        let recordSettings = [
            AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),
            AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC) as Int32),
            AVNumberOfChannelsKey : NSNumber(value: 1 as Int32),
            AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32),
        ]
        
        do {
            let audioRecorder = try AVAudioRecorder(url: url, settings: recordSettings)
            audioRecorder.prepareToRecord()
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
            recordForever(audioRecorder: audioRecorder)
            self.audioRecorder = audioRecorder
        } catch let err {
            print("Unable start recording", err)
        }
    }
    
    func stopListening() {
        // Check if the audio engine is already recording.
        if audioEngine.isRunning {
            audioEngine.stop()
        }
    }
    
    func addAudio(buffer: AVAudioPCMBuffer, audioTime: AVAudioTime) {
        // Add the audio to the current match request.
        session.matchStreamingBuffer(buffer, at: audioTime)
    }
    
    func configureAudioEngine() {
        // Get the native audio format of the engine's input bus.
        let inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        
        // Set an output format compatible with ShazamKit.
        let outputFormat = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)
        
        // Create a mixer node to convert the input.
        audioEngine.attach(mixerNode)

        // Attach the mixer to the microphone input and the output of the audio engine.
        audioEngine.connect(audioEngine.inputNode, to: mixerNode, format: inputFormat)
        audioEngine.connect(mixerNode, to: audioEngine.outputNode, format: outputFormat)
            
        // Install a tap on the mixer node to capture the microphone audio.
        mixerNode.installTap(onBus: 0,
                             bufferSize: 8192,
                             format: outputFormat) { buffer, audioTime in
            // Add captured audio to the buffer used for making a match.
            self.addAudio(buffer: buffer, audioTime: audioTime)
        }
    }

}

extension NoiseDetectorViewController: SHSessionDelegate {
    // The delegate method that the session calls when matching a reference item.
    func session(_ session: SHSession, didFind match: SHMatch) {
        if let matchedItem = match.mediaItems.first,
           let title = matchedItem.title,
           let artist = matchedItem.artist,
           let matchId = matchedItem.shazamID, matchId != lastShazamItem?.matchId {
            lastShazamItem = ShazamItem(matchId: matchId, title: title, artist: artist, artwork: matchedItem.artworkURL)
            DispatchQueue.main.async {
                self.trackLabel.text = "Кажется, это\"\(title)\"" 
                self.artistLabel.text = artist
                if let url =  matchedItem.artworkURL {
                    Nuke.loadImage(with: url, into: self.artworkView) { _ in
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                            self.shazamContainer.alpha = 1.0
                            self.shazamContainer.transform = .identity
                        }
                    }
                } else {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                        self.shazamContainer.alpha = 1.0
                        self.shazamContainer.transform = .identity
                    }
                }
            }
        }
    }

    // The delegate method that the session calls when there is no match.
     func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        print("No match found.")
    }
}
