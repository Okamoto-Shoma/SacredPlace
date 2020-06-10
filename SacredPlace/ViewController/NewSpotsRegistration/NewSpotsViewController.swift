//
//  NewSpotsViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/05/28.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation


class NewSpotsViewController: UIViewController {
    
    var image: UIImage?
    var locationManager: CLLocationManager?
    
    //MARK: - Outlet
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            self.imageView.image = self.image
        }
    }
    @IBOutlet private var registrationNameTextField: UITextField!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Action
    
    /// 投稿ボタン押下処理
    /// - Parameter sender: UIButton
    @IBAction func handleRegistrationButton(_ sender: UIButton) {
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
                guard let placemark = placemarks?.first, let administrativeArea = placemark.administrativeArea, let locality = placemark.locality, error == nil else { return }
                let postDic = [
                    "name": name,
                    "caption": self.registrationNameTextField.text!,
                    "date": FieldValue.serverTimestamp(),
                    "location": GeoPoint.init(latitude: latitude, longitude: longitude),
                    "geocoder": "\(administrativeArea)\(locality)",
                ] as [String: Any]
                postRef.setData(postDic)
            }
        }
        //カメラ画面に遷移
        guard let cameraViewController = R.storyboard.camera.instantiateInitialViewController() else { return }
        cameraViewController.image = self.image
        self.present(cameraViewController, animated: true, completion: nil)
    }
    
    /// キャンセルボタン押下処理
    /// - Parameter sender: UIButton
    @IBAction func handleCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
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
