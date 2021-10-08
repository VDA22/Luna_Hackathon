import UIKit

class NavigationController: UINavigationController {
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override open var childForStatusBarHidden: UIViewController? {
        topViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
