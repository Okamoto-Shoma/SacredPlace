//
//  CameraViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/05/27.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import ARKit
import Firebase
import SceneKit
import AVFoundation
import CoreLocation

class CameraViewController: UIViewController {
    
    var image: UIImage!
    var flag = false
    var locationManager: CLLocationManager?
    
    //MARK: - Outlet
    @IBOutlet private var arSceneView: ARSCNView!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let mySession = ARSession()
        self.arSceneView.session = mySession
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        //        self.arSceneView.showsStatistics = true
        //        self.arSceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        
        //ジェスチャー処理追加
        self.registerGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        self.arSceneView.session.run(configuration)
        self.setImageToScene(image: self.image)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.arSceneView.session.pause()
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .slide}
    
    //MARK: - Action
    
    @IBAction func handleCameraButton(_ sender: UIButton) {
        let image = self.arSceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        AudioServicesPlaySystemSound(1108)
    }
    
    /// ページバック処理
    /// - Parameter sender: UIButton
    @IBAction func backToPage(_ sender: UIButton) {
        if flag == true {
            var alertTextField: UITextField?
            let alert = UIAlertController(
                title: "選択している画像を保存しますか？",
                message: "保存する場合は登録名を入力して下さい",
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                alertTextField = textField
            })
            
            alert.addAction(UIAlertAction(title: "登録しない", style: UIAlertAction.Style.cancel) {(action: UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(UIAlertAction(title: "登録", style: UIAlertAction.Style.default) {(action: UIAlertAction) in
                //画像をJPG形式に変換する
                guard let imageData = self.image?.jpegData(compressionQuality: 0.2) else { return }
                
                //guard let userId = Auth.auth().currentUser?.uid else { return }
                
                //画像と位置情報データ、投稿データの保存場所を定義
                let postRef = Firestore.firestore().collection(Const.PostPath).document()
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
                
                //Storageに画像をアップロード
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        //アップロード失敗
                        print(error!)
                        //投稿をキャンセルし、先頭画面に戻る
                        UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                    
                    //FireStoreに投稿データを保存する
                    guard let name = Auth.auth().currentUser?.displayName, let latitude = self.locationManager?.location?.coordinate.latitude, let longitude = self.locationManager?.location?.coordinate.longitude else { return }
                    let geocoderLocation = CLLocation(latitude: latitude, longitude: longitude)
                    let geocoder = CLGeocoder()
                    
                    geocoder.reverseGeocodeLocation(geocoderLocation) { placemarks, error in
                        guard let placemark = placemarks?.first, let administrativeArea = placemark.administrativeArea, error == nil else { return }
                        let postDic = [
                            "name": name,
                            "caption": alertTextField?.text! as Any,
                            "date": FieldValue.serverTimestamp(),
                            "location": GeoPoint.init(latitude: latitude, longitude: longitude),
                            "geocoder": "\(administrativeArea)",
                            ] as [String: Any]
                        postRef.setData(postDic)
                    }
                }
                self.dismiss(animated: true, completion: nil)
            })
            self.present(alert, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
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
    
    /// ジェスチャーを追加
    private func registerGestureRecognizer() {
        //ピンチ処理
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGesture))
        self.arSceneView.addGestureRecognizer(pinchGestureRecognizer)
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
    func setImageToScene(image: UIImage) {
        //表示場所処理
        guard let camera = self.arSceneView.pointOfView else { return }
        //カメラから500mm先の座標
        let position = SCNVector3(x: 0, y: 0, z: -0.5)
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

//MARK: - CLLocationManagerDelegate
extension CameraViewController: CLLocationManagerDelegate {
    
    /// 位置情報取得処理
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - status: CLauthorizationStatus
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            //アプリ使用中にのみ取得許可を求める
            locationManager?.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            print("DEBUG_PRINT: 位置情報取得が許可されました。")
            locationManager?.startUpdatingLocation()
            break
        case .denied:
            print("DEBUG_PRINT: 位置情報取得が拒否されました。")
            break
        default:
            print("DEBUG_PRINT: 位置情報を許可してください。")
        }
    }
    
    /// 位置情報更新処理
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - locations: CLLocation
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            print("DEBUG_PRINT: 緯度:\(location.coordinate.latitude) 経度:\(location.coordinate.longitude) 取得時刻:\(location.timestamp.description)")        }
    }
}
