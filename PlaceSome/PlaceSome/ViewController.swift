//
//  ViewController.swift
//  PlaceSome
//
//  Created by Darya Viter on 08.10.2021.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var imageView = UIImageView()
    
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
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(_:))))
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
    
    @IBAction func makePhoto(_ sender: UIButton) {
        arView.snapshot(saveToHDR: true, completion: { image in
            self.imageView.image = image
            self.imageView.frame = self.view.frame
            self.view.addSubview(self.imageView)
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }
        })
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, .zero)
    }
}
