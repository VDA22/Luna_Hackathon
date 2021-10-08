import AVFoundation
import UIKit

class ClaimViewController: UIViewController {
    
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let captureSession = AVCaptureSession()

        guard let captureDevice = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}

        captureSession.addInput(input)
        captureSession.startRunning()

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let previewLayer = self.previewLayer else { return }
        previewLayer.frame = view.frame
    }
    
    @IBAction private func back() {
        navigationController?.popViewController(animated: true)
    }
}
