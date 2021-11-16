//
//  ARRoomViewController.swift
//  Wonderful_Indonesia
//
//  Created by Martin Christian Solihin on 09.11.21.
//

import UIKit
import ARKit

class ARRoomViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    private var hud :MBProgressHUD!
    
    var currentNode: SCNNode?
    var contentsArray = ["Cetho Temple", "Jabung Temple", "Tikus Temple", "Room Portal"]
    var cell: UICollectionViewCell?
    var contentSelected: String? = ""
    
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
        
        // set the collection view
        self.contentCollectionView.dataSource = self
        self.contentCollectionView.delegate = self
        
        self.registerGestureRecognizers()
    }
    
    func registerGestureRecognizers() {
        deleteButton.addTarget(self, action: #selector(deleteContent), for: .touchUpInside)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func tapped(recognizer :UITapGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else {return}
        
        let touchCoordinates = recognizer.location(in: sceneView)
        
        // hit test horizontal surface
        let query = sceneView.raycastQuery(from: touchCoordinates, allowing: .estimatedPlane, alignment: .horizontal)!
        
        let hitTestResults = sceneView.session.raycast(query)
        
        // hit test node
        let hitTestNodeResults = sceneView.hitTest(touchCoordinates)
        
        if let hitTest = hitTestResults.first {
            if contentSelected != "" {
                self.addContent(rayCast: hitTest)
            } else if let hitNodeTest = hitTestNodeResults.first {
                let node = hitNodeTest.node
                if node.name != nil {
                    currentNode = node
                    
                    DispatchQueue.main.async {
                        self.label.isHidden = false
                        self.label.text = node.name
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.label.isHidden = true
                    }
                }
            }
        } else {
            print("not horizontal surface")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "content", for: indexPath) as! ContentCell
        cell.contentLabel.text = self.contentsArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.cell = collectionView.cellForItem(at: indexPath)
        self.contentSelected = contentsArray[indexPath.row]
        self.cell?.backgroundColor = UIColor.systemYellow
    }
    
    func addContent(rayCast: ARRaycastResult) {
        if let contentSelected = self.contentSelected {
            let scene = SCNScene(named: "art.scnassets/\(contentSelected).scn")
            let node = (scene?.rootNode.childNode(withName: contentSelected, recursively: true))!
            if (node.name == "Cetho Temple") {
                node.scale = SCNVector3Make(0.01, 0.01, 0.01)
            } else if (node.name == "Jabung Temple") {
                node.scale = SCNVector3Make(0.006, 0.006, 0.006)
            } else if (node.name == "Tikus Temple") {
                node.scale = SCNVector3Make(0.003, 0.003, 0.003)
            }
            
            let transform = rayCast.worldTransform
            let thirdColumn = transform.columns.3
            node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
            
            self.sceneView.scene.rootNode.addChildNode(node)
            
            // reset UICollectionView
            self.contentSelected = ""
            self.cell?.backgroundColor = UIColor.systemGreen
        }
    }
    
    @objc func deleteContent() {
        if currentNode != nil {
            currentNode?.removeFromParentNode()
            currentNode = nil
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
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
