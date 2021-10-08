//
//  AddPinViewController.swift
//  PlaceSome
//
//  Created by Darya Viter on 08.10.2021.
//

import UIKit

class AddPinViewController: UIViewController {
    var imageForResend: UIImage? = nil
    
    @IBOutlet var descriptionView: UIView!
    @IBOutlet var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Предложение"
        descriptionView.layer.cornerRadius = 14
        nextButton.layer.cornerRadius = 14
    }

    @IBAction func nextScreen(_ sender: UIButton) {
        //        let viewController = CreateNoticeViewController()
        //        viewController.image = image
        //        navigationController?.pushViewController(viewController, animated: true)
    }
}
