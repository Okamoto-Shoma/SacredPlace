//
//  CameraViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/05/27.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class CameraViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet private var arSceneView: ARSCNView!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.arSceneView.delegate = self
        // Do any additional setup after loading the view.
        let mySession = ARSession()
        self.arSceneView.session = mySession
        self.arSceneView.showsStatistics = true
        self.arSceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        
        //ジェスチャー処理追加
        self.registerGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        self.arSceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.arSceneView.session.pause()
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .slide}
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: - Action
    
    @IBAction func selectPhotoButton(_ sender: UIButton) {
        self.showUIImagePicker()
    }
    
    /// ページバック処理
    /// - Parameter sender: UIButton
    @IBAction func backToPage(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// ピンチ処理
    /// - Parameter sender: UIPinchGestureRecognizer
    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .changed {
            self.arSceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                if node.name == "photo" {
                    let pinchScaleX = Float(sender.scale) * node.scale.x
                    let pinchScaleY = Float(sender.scale) * node.scale.y
                    let pinchScaleZ = Float(sender.scale) * node.scale.z
                    
                    node.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
                    sender.scale = 1
                }
            }
        }
    }
    //MARK: - PrivateMethod
    
    /// フォトライブラリを開く処理
    private func showUIImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            pickerController.modalPresentationStyle = .overFullScreen
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    /// ジェスチャーを追加
    private func registerGestureRecognizer() {
        //ピンチ処理
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGesture))
        self.arSceneView.addGestureRecognizer(pinchGestureRecognizer)
        
        //タップ処理
    }
    
    /// Node作成処理
    /// - Parameters:
    ///   - image: UIImage
    ///   - position: SCNVector3
    /// - Returns: SCNNode
    private func createPhotoNode(_ image: UIImage, position: SCNVector3) -> SCNNode {
        let node = SCNNode()
        let scale: CGFloat = 0.3
        let geometry = SCNPlane(width: image.size.width * scale / image.size.height, height: scale)
        geometry.firstMaterial?.diffuse.contents = image
        node.geometry = geometry
        node.position = position

        return node
    }
    
    /// 画像追加処理
    /// - Parameter image: UIImage
    private func setImageToScene(image: UIImage) {

        //カメラから500mm先の座標
        let position = SCNVector3(x: 0, y: 0, z: -0.5)
        //表示場所処理
        guard let camera = self.arSceneView.pointOfView else { return }
        //画面中央表示
        let convertPosition = camera.convertPosition(position, to: nil)
        
        let node = self.createPhotoNode(image, position: convertPosition)
        //配置したオブジェクトを常にカメラ正面に向かせる
        let frontObject = SCNBillboardConstraint()
        //Y軸が動かないように制約を与える
        frontObject.freeAxes = SCNBillboardAxis.Y
        node.constraints = [frontObject]
        node.name = "photo"
        
        self.arSceneView.scene.rootNode.addChildNode(node)
        
        print("DEBUG_PRINT: \(node)")
    }
}

//MARK: - ARSCNViewDelegate

extension CameraViewController: ARSCNViewDelegate {
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// 画像選択時処理
    /// - Parameters:
    ///   - picker: UIImagePickerController
    ///   - info: UIImagePickerController.InfoKey
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        self.setImageToScene(image: image)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// 画面選択キャンセル処理
    /// - Parameter picker: UIImagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

