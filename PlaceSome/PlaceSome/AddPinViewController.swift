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

        descriptionView.layer.cornerRadius = 14
        nextButton.layer.cornerRadius = 14
        nextButton.backgroundColor = .black
        nextButton.setTitleColor(.white, for: .normal)

        title = "Предложение"
        navigationController?.setNavigationBarHidden(false, animated: true)

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationItem.backButtonTitle = ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"), style: .plain,
            target: self, action: #selector(popView)
        )
    }

    @IBAction func nextScreen(_ sender: UIButton) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "CreateNoticeViewController") as? CreateNoticeViewController else {
            fatalError()
        }

        controller.imageForResend = imageForResend
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func popView() {
        navigationController?.popViewController(animated: true)
    }
}
