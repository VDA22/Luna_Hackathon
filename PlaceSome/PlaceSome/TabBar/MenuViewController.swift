import UIKit

class MenuViewController: UIViewController {
    
    var proposalAction: (() -> Void)?
    var claimAction: (() -> Void)?
    
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var proposalButton: UIButton!
    @IBOutlet private var claimButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.0
        closeButton.setTitle("", for: .normal)
        proposalButton.setTitle("", for: .normal)
        claimButton.setTitle("", for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.backgroundView.alpha = 0.2
        }
    }
    
    @IBAction private func close() {
        dismiss(animated: true)
    }
    
    @IBAction private func proposal() {
        dismiss(animated: true)
        proposalAction?()
    }
    
    @IBAction private func claim() {
        dismiss(animated: true)
        claimAction?()
    }
}
