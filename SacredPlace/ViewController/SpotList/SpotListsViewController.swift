//
//  SpotListsViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/05/28.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import MapKit
import CoreLocation

class SpotListsViewController: UIViewController {
    
    private var postArray: [PostData] = []
    private var postDataReceived: [PostData] = []
    private var imageArray = Storage.storage().reference().child(Const.ImagePath)
    // Firestoreのリスナー
    private var listener: ListenerRegistration?
    private var locationManager: CLLocationManager?
    
    //MARK: - Outlet
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.register(R.nib.spotsListTableViewCell)
            self.tableView.backgroundColor = .black
        }
    }
    @IBOutlet private var mapView: MKMapView!
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startUpdatingLocation()
        self.dateCheck()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.mapView.mapType = .standard
        //現在地
        self.mapView.setCenter(self.mapView.userLocation.coordinate, animated: true)
        self.mapView.userTrackingMode = MKUserTrackingMode.follow
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.locationManager?.stopUpdatingLocation()
    }
    
    //MARK: - PrivateMethod

    /// Firebaseから情報を取得
    private func dateCheck () {
        if Auth.auth().currentUser != nil {
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "caption", descending: false)
            self.listener = postsRef.addSnapshotListener() { (QuerySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                }
                //取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                self.postArray = QuerySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    
                    return postData
                    
                    self.imageArray = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
                }
            }
        }
        self.locationUpDate()
    }
    
    /// 位置情報取得開始
    private func startUpdatingLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            self.locationManager?.requestWhenInUseAuthorization()
        default:
            break
        }
        self.locationManager?.startUpdatingLocation()
    }
    
    /// 現在地に近い場所のみ配列にする
    private func locationUpDate() {
        guard let baseLatitude = self.locationManager?.location?.coordinate.latitude, let baseLongitude = self.locationManager?.location?.coordinate.longitude else { return }
        let baseLocation = CLLocation(latitude: baseLatitude, longitude: baseLongitude)
        
        self.postDataReceived = self.postArray.filter({
            baseLocation.distance(from: CLLocation(latitude: $0.location?.latitude ?? 0, longitude: $0.location?.longitude ?? 0)) < 20
        })
        self.tableView.reloadData()
        print("DEBUG_PRINT: \(self.postDataReceived)")
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource

extension SpotListsViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// 行数/列数
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - section: Int
    /// - Returns: self.postArray.count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postDataReceived.count
    }
    
    /// セル内容
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: IndexPath
    /// - Returns: cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.nib.spotsListTableViewCell.identifier, for: indexPath) as! SpotsListTableViewCell
        let postData = self.postDataReceived[indexPath.row]
        
        //各表示設定
        guard let caption = postData.caption, let baseLatitude = self.locationManager?.location?.coordinate.latitude, let baseLongitude = self.locationManager?.location?.coordinate.longitude, let geocoder = postData.geocoder, let targetLatitude = postData.location?.latitude, let targetLongitude = postData.location?.longitude else { return cell }
        
        //タイトル表示
        cell.title = caption
        //場所表示
        cell.geocoder = geocoder
        //現在地からの距離表示
        let baseLocation = CLLocation(latitude: baseLatitude, longitude: baseLongitude)
        // 登録地
        let targetLocation = CLLocation(latitude: targetLatitude, longitude: targetLongitude)
        // 距離
        let distance = baseLocation.distance(from: targetLocation)
        cell.distance = distance
        //FirebaseStorageから画像を取得
        //let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        let imageRef = self.imageArray.child(postData.id + ".jpg")
        //一覧に画像表示
        cell.postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.postImageView.sd_setImage(with: imageRef)
        print("DEBUG_PRINT: \(imageRef)")
        //AR画面に画像表示処理
        imageRef.getData(maxSize: 1 * 1024 * 1024) { (image, error) in
            if error != nil {
                return
            }
            let image = UIImage(data: image!)
            //カメラボタン処理
            cell.self.cameraButton.tag = indexPath.row
            cell.buttonTapAction = {
                guard let cameraViewController = R.storyboard.camera.instantiateInitialViewController() else { return }
                cameraViewController.image = image
                self.present(cameraViewController, animated: true, completion: nil)
                print("DEBUG_PRINT: 撮影ボタンが押されました。")
            }
        }
        return cell
    }
    
    /// タップ時処理
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: IndexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postData = self.postArray[indexPath.row]
        guard let latitude = postData.location?.latitude, let longitude = postData.location?.longitude else { return }
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: center, span: span)
        self.mapView.setRegion(region, animated: true)
    }
}


//MARK: - CLLocationManagerDelegate

extension SpotListsViewController: CLLocationManagerDelegate {
    
    /// 位置情報取得処理
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - status: CLauthorizationStatus
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            //アプリ使用中にのみ取得許可を求める
            self.locationManager?.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            print("DEBUG_PRINT: 位置情報取得が許可されました。")
            self.locationManager?.startUpdatingLocation()
        case .denied:
            print("DEBUG_PRINT: 位置情報取得が拒否されました。")
        default:
            print("DEBUG_PRINT: 位置情報を許可してください。")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastlocation = locations.last
        guard let last = lastlocation else { return }
        let eventDate = last.timestamp
        if abs(eventDate.timeIntervalSinceNow) < 100.0 {
            
            self.locationUpDate()
        }
    }
}


