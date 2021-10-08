import UIKit
import Nuke

class NoiseClaimViewController: UIViewController {
    
    var shazamItem: ShazamItem?
    
    @IBOutlet private var trackLabel: UILabel!
    @IBOutlet private var artistLabel: UILabel!
    @IBOutlet private var artworkView: UIImageView!
    @IBOutlet private var shazamContainer: UIView!
    @IBOutlet private var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.trackLabel.text = shazamItem?.title
        self.artistLabel.text = shazamItem?.artist
        if let url =  shazamItem?.artwork {
            Nuke.loadImage(with: url, into: self.artworkView)
        }
        
        nextButton.layer.cornerRadius = 14
        nextButton.backgroundColor = .black
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.tintColor = .white
    }
    
    @IBAction private func back() {
        navigationController?.popViewController(animated: true)
    }
}
