import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .black
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
        delegate = self
    }
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {

        if viewController == tabBarController.viewControllers?[2] {
            let vc = makeMenu()
            present(vc, animated: true)
            return false
        } else {
            return true
        }
    }
    
    private func makeMenu() -> UIViewController {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "Menu") as? MenuViewController else {
            fatalError()
        }
        vc.proposalAction = { [unowned self] in
            let vc = self.makeProposalVC()
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
        vc.claimAction = { [unowned self] in
            let vc = self.makeClaimVC()
            self.viewControllers![0].show(vc, sender: nil)
        }
        return vc
    }
    
    private func makeProposalVC() -> UIViewController {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "Proposal") as? CreatePhotoOfSuggestion else {
            fatalError()
        }
        let navigation = UINavigationController()
        navigation.viewControllers = [vc]
        return navigation
    }
    
    private func makeClaimVC() -> UIViewController {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "Claim") as? ClaimViewController else {
            fatalError()
        }
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
}
