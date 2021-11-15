//
//  ARBookViewController.swift
//  Wonderful_Indonesia
//
//  Created by Martin Christian Solihin on 13.10.21.
//

import UIKit
import ARKit

private var countTapped: Int = 0

class ARBookViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    private var currentCase: String = ""
    private var currentAngleY: Float = 0.0
    private var newAngleY: Float = 0.0
    
    private var audioPlayer: AVAudioPlayer?
    
    private var iconPlay = UIImage(named: "art.scnassets/images/play.png")
    private var iconWave = UIImage(named: "art.scnassets/images/wave.png")
    
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
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func tapped(recognizer :UITapGestureRecognizer) {
        countTapped += 1
        if countTapped > 2 {countTapped = 0}
        
        guard let sceneView = recognizer.view as? ARSCNView else {return}
        
        let touchCoordinates = recognizer.location(in: sceneView)
        
        let hitTestResults = sceneView.hitTest(touchCoordinates)
        
        if let hitTest = hitTestResults.first {
            let node = hitTest.node
            print(node.name ?? "unknown")
            
            switch currentCase {
            case "Proclamation Leaders":
                node.geometry?.firstMaterial?.diffuse.contents = UIImage.leader()
            case "Proclamation":
                if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
                    node.geometry?.firstMaterial?.diffuse.contents = iconPlay
                    audioPlayer.stop()
                } else {
                    node.geometry?.firstMaterial?.diffuse.contents = iconWave
                    audioPlayer?.play()
                }
            default:
                break
            }
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
    
    @objc func longPressed(recognizer :UITapGestureRecognizer) {
        if recognizer.state == .began {
            guard let sceneView = recognizer.view as? ARSCNView else {return}
            
            let touchCoordinates = recognizer.location(in: sceneView)
            
            let hitTestResults = sceneView.hitTest(touchCoordinates)
            
            if let hitTest = hitTestResults.first {
                let nodeParent = hitTest.node.parent!
                let node = hitTest.node
                if node.name == "Tikus Temple" {
                    nodeParent.childNode(withName: "panel", recursively: false)?.isHidden = false
                    node.isHidden = true
                } else if node.name == "panel"{
                    nodeParent.childNode(withName: "Tikus Temple", recursively: false)?.isHidden = false
                    node.isHidden = true
                }
            } else {
                print("no object found")
            }
        } else if recognizer.state == .ended {
            print("ended")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            DispatchQueue.main.async {
                self.label.isHidden = false
                
                if let name = imageAnchor.referenceImage.name {
                    self.currentCase = name
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
                        imageLeader.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/images/Ir. Sukarno.png")
                        
                        // display name text
                        /*
                        guard let nameLeader = nodeLeadersContainer.childNode(withName: "name", recursively: false) else {return}
                        nameLeader.isHidden = false
                        */
                    case "Indonesian Ancestors":
                        // replace label with object's name
                        self.label.text = name
                        
                        // display container
                        guard let sceneVideo = SCNScene(named: "art.scnassets/video.scn") else {return}
                        guard let nodeVideoContainer = sceneVideo.rootNode.childNode(withName: "container", recursively: false) else {return}
                        nodeVideoContainer.removeFromParentNode()
                        node.addChildNode(nodeVideoContainer)
                        nodeVideoContainer.isHidden = false
                        
                        // display video
                        let videoURL = Bundle.main.url(forResource: "art.scnassets/video indonesian ancestors", withExtension: "mov")
                        let videoPlayer = AVPlayer(url: videoURL!)
                        
                        let spriteKitScene = SKScene(size: CGSize(width: 640.0, height: 480.0))
                        
                        let nodeVideo = SKVideoNode(avPlayer: videoPlayer)
                        nodeVideo.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
                        nodeVideo.size = spriteKitScene.size
                        nodeVideo.yScale = -1
                        nodeVideo.play()
                        
                        spriteKitScene.addChild(nodeVideo)
                        
                        guard let video = nodeVideoContainer.childNode(withName: "panel", recursively: false) else {return}
                        video.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
                    case "Proclamation":
                        // replace label with object's name
                        self.label.text = name
                        
                        // display container
                        guard let sceneAudio = SCNScene(named: "art.scnassets/audio.scn") else {return}
                        guard let nodeAudioContainer = sceneAudio.rootNode.childNode(withName: "container", recursively: false) else {return}
                        nodeAudioContainer.removeFromParentNode()
                        node.addChildNode(nodeAudioContainer)
                        nodeAudioContainer.isHidden = false
                        
                        // display icon
                        guard let imageIcon = nodeAudioContainer.childNode(withName: "panel", recursively: false) else {return}
                        imageIcon.geometry?.firstMaterial?.diffuse.contents = self.iconPlay
                        
                        // play audio
                        let audioURL = Bundle.main.path(forResource: "art.scnassets/audio proclamation", ofType: "mp3")
                        do {
                            try AVAudioSession.sharedInstance().setMode(.default)
                            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                            
                            guard let audioURL = audioURL else {return}
                            
                            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioURL))
                            
                            guard let audioPlayer = self.audioPlayer else {return}
                            
                            audioPlayer.stop()
                        } catch {
                            print(error)
                        }
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

extension UIImage {
    static func leader() -> UIImage {
        var imageLeader = UIImage()
        
        if countTapped == 1 {
            imageLeader = UIImage(named: "art.scnassets/images/Moh. Hatta.jpg")!
        } else if countTapped == 2 {
            imageLeader = UIImage(named: "art.scnassets/images/Ahmad Subarjo.jpg")!
        } else {
            imageLeader = UIImage(named: "art.scnassets/images/Ir. Sukarno.png")!
        }
        
        return imageLeader
    }
}
