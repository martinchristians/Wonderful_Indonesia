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
    
    private var currentAngleY: Float = 0.0
    private var newAngleY: Float = 0.0
    
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
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned))
        self.sceneView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func tapped(recognizer :UITapGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else {return}
        
        let touchCoordinates = recognizer.location(in: sceneView)
        
        let hitTestResults = sceneView.hitTest(touchCoordinates)
        
        if let hitTest = hitTestResults.first {
            let node = hitTest.node
            print(node.name ?? "unknown")
        } else {
            print("no object found")
        }
    }
    
    @objc func pinched(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .changed {
            guard let sceneView = recognizer.view as? ARSCNView else {return}
            
            let touchCoordinates = recognizer.location(in: sceneView)
            
            let hitTestResults = sceneView.hitTest(touchCoordinates)
            
            if let hitTest = hitTestResults.first {
                let node = hitTest.node
                let pinchAction = SCNAction.scale(by: recognizer.scale, duration: 0)
                node.runAction(pinchAction)
                recognizer.scale = 1
            } else {
                print("no object found")
            }
        }
    }
    
    @objc func panned(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .changed {
            guard let sceneView = recognizer.view as? ARSCNView else {return}
            
            let touchCoordinates = recognizer.location(in: sceneView)
            let translation = recognizer.translation(in: sceneView)
            
            let hitTestResults = sceneView.hitTest(touchCoordinates)
            
            if let hitTest = hitTestResults.first {
                let node = hitTest.node.parent!
                self.newAngleY = Float(translation.x) * Float(Double.pi / 180)
                self.newAngleY += self.currentAngleY
                node.eulerAngles.y = self.newAngleY
            } else {
                print("no object found")
            }
        } else if recognizer.state == .ended {
            self.currentAngleY = self.newAngleY
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
                    case "Map of Indonesia":
                        // replace label with object's name
                        self.label.text = name
                        
                        // display image
                        guard let sceneMap = SCNScene(named: "art.scnassets/map_indonesia.scn") else {return}
                        guard let nodeMapContainer = sceneMap.rootNode.childNode(withName: "container", recursively: false) else {return}
                        nodeMapContainer.removeFromParentNode()
                        node.addChildNode(nodeMapContainer)
                        nodeMapContainer.isHidden = false
                    case "Proclamation Leaders":
                        // replace label with object's name
                        self.label.text = name
                        
                        // display container
                        guard let sceneLeaders = SCNScene(named: "art.scnassets/proclamation_leaders.scn") else {return}
                        guard let nodeLeadersContainer = sceneLeaders.rootNode.childNode(withName: "container", recursively: false) else {return}
                        nodeLeadersContainer.removeFromParentNode()
                        node.addChildNode(nodeLeadersContainer)
                        nodeLeadersContainer.isHidden = false
                        
                        // display image
                        guard let imageLeader = nodeLeadersContainer.childNode(withName: "panel", recursively: false) else {return}
                        imageLeader.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/images/Ir. Sukarno")
                        
                        // display name text
                        guard let nameLeader = nodeLeadersContainer.childNode(withName: "name", recursively: false) else {return}
                        nameLeader.isHidden = false
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

