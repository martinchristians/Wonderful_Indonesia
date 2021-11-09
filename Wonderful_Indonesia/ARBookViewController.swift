//
//  ARBookViewController.swift
//  Wonderful_Indonesia
//
//  Created by Martin Christian Solihin on 13.10.21.
//

import UIKit
import ARKit

class ARBookViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var planeDetection: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AR BOOK"
        
        // set the view's delegate
        sceneView.delegate = self
        
        // create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARImageAnchor {
            DispatchQueue.main.async {
                self.planeDetection.isHidden = false
                self.planeDetection.text = "Object found!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.planeDetection.isHidden = true
                }
            }
        } else {
            return
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARImageTrackingConfiguration()
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {fatalError("Missing expected asset catalog resources!")}
        
        configuration.trackingImages = referenceImages
        
        self.sceneView.session.run(configuration)
    }

}

