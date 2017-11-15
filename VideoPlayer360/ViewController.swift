//
//  ViewController.swift
//  VideoPlayer360
//
//  Created by William Archimède on 15/11/2017.
//  Copyright © 2017 William Archimede. All rights reserved.
//

import UIKit
import SpriteKit
import SceneKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: SCNView!

    let motionManager = CMMotionManager()
    let cameraNode = SCNNode()
    private var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    @IBAction func play(_ sender: UIButton) {
        sender.isHidden = true
        sceneView.play(nil)
        player.play()
    }
}

extension ViewController {
    private func setup() {
        // Do any additional setup after loading the view, typically from a nib.
        let urlString = "http://kolor.com/360-videos-files/kolor-balloon-icare-full-hd.mp4"
        guard let url = URL(string: urlString) else {
            fatalError("Failed to create URL")
        }

        let scene = SCNScene()
        setupSceneView(with: scene)

        let player = playerSpriteScene(with: url)
        let sphere = sphereNode(with: player)
        scene.rootNode.addChildNode(sphere)

        setupCamera()
        scene.rootNode.addChildNode(cameraNode)

        startDeviceMotionUpdates(for: cameraNode)
    }

    private func setupSceneView(with scene: SCNScene) {
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.allowsCameraControl = false
    }

    private func playerSpriteScene(with url: URL) -> SKScene {
        player = AVPlayer(url: url)
        let videoNode = SKVideoNode(avPlayer: player)
        let size = view.frame.size
        videoNode.size = size
        videoNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        let spriteScene = SKScene(size: size)
        spriteScene.addChild(videoNode)

        return spriteScene
    }

    private func sphereNode(with material: SKScene) -> SCNNode {
        // Create node, containing a sphere, using the panoramic image as a texture
        let sphere = SCNSphere(radius: 100.0)
        sphere.firstMaterial?.isDoubleSided = true
        sphere.firstMaterial?.diffuse.contents = material
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3Make(0, 0, 0)

        return sphereNode
    }

    private func setupCamera() {
        // Set the camera at the center of the sphere
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 0)
    }

    private func startDeviceMotionUpdates(for node: SCNNode) {
        guard motionManager.isDeviceMotionAvailable else {
            return
        }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { deviceMotion, error in
            guard let deviceMotion = deviceMotion, error == nil else {
                return
            }

            let attitude = deviceMotion.attitude
            let roll = Float(.pi/2 - attitude.roll)
            let yaw = -Float(attitude.yaw)
            let pitch = Float(attitude.pitch)
            node.eulerAngles = SCNVector3Make(roll, yaw, pitch)
        }
    }
}
