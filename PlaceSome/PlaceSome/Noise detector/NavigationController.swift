import UIKit

class NavigationController: UINavigationController {
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
