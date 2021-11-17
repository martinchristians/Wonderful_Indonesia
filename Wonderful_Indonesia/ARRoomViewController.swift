//
//  ARRoomViewController.swift
//  Wonderful_Indonesia
//
//  Created by Martin Christian Solihin on 09.11.21.
//

import UIKit
import ARKit

class ARRoomViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ARSessionDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteRoomButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    private var hud :MBProgressHUD!
    
    var currentNode: SCNNode?
    var contentsArray = ["Cetho Temple", "Jabung Temple", "Tikus Temple", "Room Portal"]
    var cell: UICollectionViewCell?
    var contentSelected: String? = ""
    
    private var currentAngleY: Float = 0.0
    private var newAngleY: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AR ROOM"
        
        self.hud = MBProgressHUD.showAdded(to: self.sceneView, animated: true)
        self.hud.label.text = "Detecting plane..."
        
        // debugging
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.showsStatistics = true
        
        // lighting
        self.sceneView.autoenablesDefaultLighting = true
        
        // set the view's delegate
        self.sceneView.delegate = self
        self.sceneView.session.delegate = self
        
        // set the collection view
        self.contentCollectionView.dataSource = self
        self.contentCollectionView.delegate = self
        
        self.registerGestureRecognizers()
    }
    
    func registerGestureRecognizers() {
        deleteButton.addTarget(self, action: #selector(deleteContent), for: .touchUpInside)
        deleteRoomButton.addTarget(self, action: #selector(deleteRoomContent), for: .touchUpInside)
        
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
            let parentName: String = contentSelected + " Parent"
            let node = (scene?.rootNode.childNode(withName: parentName, recursively: false))!
            if (node.name == "Cetho Temple Parent") {
                node.scale = SCNVector3Make(0.01, 0.01, 0.01)
            } else if (node.name == "Jabung Temple Parent") {
                node.scale = SCNVector3Make(0.008, 0.008, 0.008)
            } else if (node.name == "Tikus Temple Parent") {
                node.scale = SCNVector3Make(0.003, 0.003, 0.003)
            } else if (node.name == "Room Portal Parent") {
                deleteRoomButton.isHidden = false
                
                // change rendering order
                self.changeRenderingOrder(nodeName: "box cetho", node: node)
                self.changeRenderingOrder(nodeName: "Cetho Temple", node: node)
                self.changeRenderingOrder(nodeName: "box jabung", node: node)
                self.changeRenderingOrder(nodeName: "Jabung Temple", node: node)
                self.changeRenderingOrder(nodeName: "box tikus", node: node)
                self.changeRenderingOrder(nodeName: "Tikus Temple", node: node)
                
                self.changeRenderingOrder(nodeName: "roof", node: node)
                self.changeRenderingOrder(nodeName: "floor", node: node)
                self.changeRenderingOrder(nodeName: "backWall", node: node)
                self.changeRenderingOrder(nodeName: "sideWallA", node: node)
                self.changeRenderingOrder(nodeName: "sideWallB", node: node)
                self.changeRenderingOrder(nodeName: "sideDoorA", node: node)
                self.changeRenderingOrder(nodeName: "sideDoorB", node: node)
                self.changeRenderingOrder(nodeName: "upperDoor", node: node)
                
                // animation
                self.animateNode(nodeName: "Cetho Temple Parent", node: node, scaleSize: 0.006)
                self.animateNode(nodeName: "Jabung Temple Parent", node: node, scaleSize: 0.002)
                self.animateNode(nodeName: "Tikus Temple Parent", node: node, scaleSize: 0.002)
            }
            node.removeFromParentNode()
            
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
    
    @objc func deleteRoomContent() {
        deleteRoomButton.isHidden = true
        
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if (node.name == "Room Portal Parent") {
                node.removeFromParentNode()
            }
        }
    }
    
    func changeRenderingOrder(nodeName: String, node: SCNNode) {
        let child = node.childNode(withName: nodeName, recursively: true)
        child?.renderingOrder = 200
        
        // change transparency for the masks
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.001
        }
    }
    
    func animateNode(nodeName: String, node: SCNNode, scaleSize: Float) {
        guard let child = node.childNode(withName: nodeName, recursively: true) else {return}
        
        // rotate animation
        let rotateAction = SCNAction.rotateBy(x: 0, y: 0.5, z: 0, duration: 3)
        let runForever = SCNAction.repeatForever(rotateAction)
        child.runAction(runForever)
        
        // scale animation
        let rescale = CABasicAnimation(keyPath: "transform.scale")
        rescale.fromValue = child.presentation.scale
        rescale.toValue = SCNVector3(x: child.presentation.scale.x + scaleSize, y: child.presentation.scale.y + scaleSize, z: child.presentation.scale.z + scaleSize)
        rescale.duration = 5
        rescale.autoreverses = true
        rescale.repeatCount = .infinity
        child.addAnimation(rescale, forKey: "transform.scale")
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
        
        restoreMap()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable:
            self.statusLabel.text = "NOT AVAILABE"
        case .limited:
            self.statusLabel.text = "LIMITED"
        case .extending:
            self.statusLabel.text = "EXTENDING"
        case .mapped:
            self.statusLabel.text = "MAPPED"
        @unknown default:
            fatalError()
        }
    }
    
    @IBAction func save(_ sender: Any) {
        self.sceneView.session.getCurrentWorldMap { worldMap, error in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            
            if let map = worldMap {
                let data = try! NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                                
                // save in user defaults
                let userDefaults = UserDefaults.standard
                userDefaults.set(data, forKey: "wonderful_indonesia")
                userDefaults.synchronize()
                
                self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.hud.label.text = "Map Saved!"
                self.hud.hide(animated: true, afterDelay: 1)
            }
        }
    }
    
    func restoreMap() {
        let userDefaults = UserDefaults.standard
        
        if let data = userDefaults.data(forKey: "wonderful_indonesia") {
            if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data),
               let worldMap = unarchived as? ARWorldMap {
                let configuration = ARWorldTrackingConfiguration()
                
                configuration.initialWorldMap = worldMap
                
                configuration.planeDetection = .horizontal
                
                self.sceneView.session.run(configuration)
            }
        } else {
            let configuration = ARWorldTrackingConfiguration()
            
            configuration.planeDetection = .horizontal
            
            self.sceneView.session.run(configuration)
        }
    }
}
