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
    
    @IBAction private func next() {
        let activity = storyboard!.instantiateViewController(withIdentifier: "Activity")
        activity.view.alpha = 0
        activity.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(activity.view)
        UIView.animate(withDuration: 0.3) {
            activity.view.alpha = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard let vc = self.navigationController?.viewControllers.first as? MainViewController else { return }
            vc.showNoiseCard()
            vc.hidesBottomBarWhenPushed = false
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
