//
//  ARRoomViewController.swift
//  Wonderful_Indonesia
//
//  Created by Martin Christian Solihin on 09.11.21.
//

import UIKit
import ARKit

class ARRoomViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    private var hud :MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AR ROOM"
        
        self.hud = MBProgressHUD.showAdded(to: self.sceneView, animated: true)
        self.hud.label.text = "Detecting plane..."
        
        // debugging
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.showsStatistics = true
        
        // lighting
        self.sceneView.autoenablesDefaultLighting = true
        
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
        
        let touchCoordinates = recognizer.location(in: sceneView)
        
        let hitTestResults = sceneView.hitTest(touchCoordinates, types: .existingPlane)
        
        if let hitTest = hitTestResults.first {
            print("surface detected")
        } else {
            print("not horizontal surface")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            DispatchQueue.main.async {
                self.hud.label.text = "Plane detected!"
                self.hud.hide(animated: true, afterDelay: 1)
            }
        } else {
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        self.sceneView.session.run(configuration)
    }
}
