//
//  ViewController.swift
//  PlaceSome
//
//  Created by Darya Viter on 08.10.2021.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    // MARK: - UI

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet var arView: ARView!
    @IBOutlet weak var bottomView: UIView!
    var imageView = UIImageView()


    var isNormal = false
    var session: ARSession {
        arView.session
    }
    // MARK: - Lifecicle

    override func viewDidLoad() {
        super.viewDidLoad()

        Experience.loadBoxAsync { result in
            do {
                let boxScene = try result.get()
                self.arView.scene.addAnchor(boxScene)
            } catch {
                print(error)
            }
        }

        titleView.layer.cornerRadius = 14
        arView.session.delegate = self
        loader.startAnimating()
        bottomView.layer.cornerRadius = 14

        navigationController?.title = "Предложение"
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.setNavigationBarHidden(false, animated: true)

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "24px"), style: .plain,
            target: self, action: #selector(closeView))

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(_:))))
    }

    override func viewWillLayoutSubviews() {
    }

    // MARK: - Actions
    @IBAction func makePhoto(_ sender: UIButton) {
        resetTracking()
        arView.snapshot(saveToHDR: true, completion: { image in
            self.imageView.image = image
            self.imageView.frame = self.view.frame
            self.view.addSubview(self.imageView)
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }
        })
    }

    @IBAction func resetTracking(_ sender: UIButton) {
        resetTracking()
    }

    /// Creates a new AR configuration to run on the `session`.
    func resetTracking() {
        loader.isHidden = false
        loader.startAnimating()

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    @objc private func closeView() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc private func didTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        let tapLocation = gesture.location(in: arView)
        let results = self.arView.hitTest(tapLocation, types: .featurePoint)
        guard let result = results.first else { return }
        let entity = arView.entity(at: point)
        let translation = result.worldTransform.translation
        entity?.setPosition(translation, relativeTo: entity)
    }

    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard isNormal, session.currentFrame?.anchors.count ?? 0 > 1 else { return }

        loader.stopAnimating()
        loader.isHidden = true
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard !loader.isAnimating else { return }

        loader.startAnimating()
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable, .limited:
            isNormal = false
            print("not normal")
        case .normal:
            isNormal = true
            print("normal")
        }
    }
}
