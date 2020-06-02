//
//  NewSpotsViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/05/28.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import CoreLocation


class NewSpotsViewController: UIViewController {
    
    var image: UIImage!
    var locationManager: CLLocationManager!
    
    //MARK: - Outlet
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private var registrationNameTextField: UITextField!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = image
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Action
    
    /// 投稿ボタン押下処理
    /// - Parameter sender: UIButton
    @IBAction func handleRegistrationButton(_ sender: UIButton) {
        //画像をPNG形式に変換する
        let imageData = image.pngData()
        //画像と位置情報データ、投稿データの保存場所を定義
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + "png")
       
        //Storageに画像をアップロード
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            if error != nil {
                //アップロード失敗
                print(error!)
                //投稿をキャンセルし、先頭画面に戻る
                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
            }
            
            //FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            let posDic = [
                "name": name!,
                "caption": self.registrationNameTextField.text!,
                "date": FieldValue.serverTimestamp(),
                "location": GeoPoint.init(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!),
                ] as [String: Any]
            postRef.setData(posDic)
            
        }
        //カメラ画面に遷移
        let storyboard = UIStoryboard(name: "Camera", bundle: nil)
        guard let cameraViewController = storyboard.instantiateViewController(withIdentifier: "Camera") as? CameraViewController else { return }
        cameraViewController.image = image
        self.present(cameraViewController, animated: true, completion: nil)
    }
    
    /// キャンセルボタン押下処理
    /// - Parameter sender: UIButton
    @IBAction func handleCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//MARK: - CLLocationManagerDelegate
extension NewSpotsViewController: CLLocationManagerDelegate {
    
    /// 位置情報取得処理
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - status: CLauthorizationStatus
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            //アプリ使用中にのみ取得許可を求める
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            print("DEBUG_PRINT: 位置情報取得が許可されました。")
            locationManager.startUpdatingLocation()
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
