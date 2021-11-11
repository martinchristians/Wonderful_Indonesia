//
//  ARBookViewController.swift
//  Wonderful_Indonesia
//
//  Created by Martin Christian Solihin on 13.10.21.
//

import UIKit
import ARKit

class ARBookViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AR BOOK"
        
        // set the view's delegate
        sceneView.delegate = self
        
        self.registerGestureRecognizers()
    }
    
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer :UITapGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else {return}
        
        let touch = recognizer.location(in: sceneView)
        
        let hitTestResults = sceneView.hitTest(touch, types: .existingPlane)
        
        if hitTestResults.isEmpty {
            print("no object found")
        } else {
            print("tapped object")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            DispatchQueue.main.async {
                self.label.isHidden = false
                
                if let name = imageAnchor.referenceImage.name {
                    switch name {
                    case "Tikus Temple":
                        // replace label with object's name
                        self.label.text = name
                        
                        // display 3D model
                        guard let sceneTikusTemple = SCNScene(named: "art.scnassets/candi_tikus.scn") else {return}
                        guard let nodeTikusTemple = sceneTikusTemple.rootNode.childNode(withName: "Tikus Temple Parent", recursively: false) else {return}
                        nodeTikusTemple.removeFromParentNode()
                        node.addChildNode(nodeTikusTemple)
                        nodeTikusTemple.isHidden = false
                    default:
                        self.label.text = name
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.label.isHidden = true
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

