//
//  CreateNoticeViewController.swift
//  PlaceSome
//
//  Created by Darya Viter on 08.10.2021.
//

import UIKit

class CreateNoticeViewController: UIViewController {
    var imageForResend: UIImage? = nil

    @IBOutlet weak var imageOfSuggestion: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var views: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Предложение"
        imageOfSuggestion.image = imageForResend
        views.forEach { $0.layer.cornerRadius = 14 }
        nextButton.layer.cornerRadius = 14
        nextButton.backgroundColor = .black
        nextButton.setTitleColor(.white, for: .normal)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"), style: .plain,
            target: self, action: #selector(popView)
        )
    }

    @IBAction func nextScreen(_ sender: UIButton) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "SuggestionCompletedViewController") as? SuggestionCompletedViewController else {
            fatalError()
        }

        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func popView() {
        navigationController?.popViewController(animated: true)
    }
}
