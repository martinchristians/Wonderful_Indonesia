//
//  ARRoomViewController.swift
//  Wonderful_Indonesia
//
//  Created by Martin Christian Solihin on 09.11.21.
//

import UIKit
import ARKit

class ARRoomViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    private var hud :MBProgressHUD!
    
    var contentsArray = ["Cetho Temple", "Jabung Temple", "Tikus Temple", "Room Portal"]
    
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "content", for: indexPath) as! ContentCell
        cell.contentLabel.text = self.contentsArray[indexPath.row]
        return cell
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
