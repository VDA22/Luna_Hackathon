import UIKit

final class MainViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    
    private let deafultCardImage = UIImage(named: "Reminder")!
    private let noiseCardImage = UIImage(named: "noise_main")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = deafultCardImage
    }
    
    func showNoiseCard() {
        imageView.image = noiseCardImage
    }
}
