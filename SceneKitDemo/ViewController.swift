import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var configuration = ARWorldTrackingConfiguration()
    
    var session: ARSession {
        return sceneView.session
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.setupConfig()
            self.setupScene()
            self.setupLight()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Setup
    
    func setupScene() {
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        let scene = SCNScene(named: "art.scnassets/Scene.scn")!
        self.sceneView.scene = scene
        
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
    }
    
    func setupConfig() {
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        session.run(configuration)
    }
    
    func setupLight() {
        sceneView.autoenablesDefaultLighting = false
        sceneView.automaticallyUpdatesLighting = false
    }
    
    // MARK: ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        DispatchQueue.main.async {
            let sceneNode = self.sceneView.scene.rootNode.childNode(withName: "sceneNode", recursively: true)!
            sceneNode.simdPosition = float3(planeAnchor.center.x, 0, -1)
            node.addChildNode(sceneNode)
            
            self.configuration.planeDetection = []
            self.session.run(self.configuration)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNode(withName: "desert", recursively: true),
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
}

