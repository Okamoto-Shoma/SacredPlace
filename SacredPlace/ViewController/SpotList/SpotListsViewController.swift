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
    // Firestoreのリスナー
    private var listener: ListenerRegistration?
    private var locationManager: CLLocationManager?
    
    //MARK: - Outlet
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.register(R.nib.spotsListTableViewCell)
            self.tableView.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        }
    }
    @IBOutlet private var mapView: MKMapView!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()

        
        self.mapView.delegate = self

        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.locationManager?.delegate = self
        self.tableView.reloadData()
        self.dateCheck()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupMapLocation()
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
                    //print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    return postData
                }
                self.locationUpDate()
            }
        }
    }
    
    /// 地図設定
    private func setupMapLocation() {
        //マップタイプ
        self.mapView.mapType = .standard
        //現在地設定
        self.mapView.showsUserLocation = true
        self.mapView.tintColor = .green
        self.mapView.userTrackingMode = MKUserTrackingMode.follow
        //現在地センタリング
        self.mapView.setCenter(self.mapView.userLocation.coordinate, animated: true)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: self.mapView.centerCoordinate, span: span)
        self.mapView.region = region
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
        self.setupPin()
    }
    
    /// ピン設定
    private func setupPin() {
        _ = self.postDataReceived.map({
            //登録名
            let caption = $0.caption
            //緯度・経度
            let latitude = $0.location?.latitude
            let longitude = $0.location?.longitude
            
            self.addAnnotation(latitude ?? 0, longitude ?? 0, caption ?? "")
        })
    }
    
    /// ピン表示設定
    /// - Parameters:
    ///   - latitude: CLLocationDegrees
    ///   - longitude: CLLocationDegrees
    ///   - title: String
    private func addAnnotation(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, _ title: String) {
        //ピンの生成
        let annotation = MKPointAnnotation()
        //緯度経度の指定
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        //タイトルを設定
        annotation.title = title
        //mapViewに追加
        self.mapView.addAnnotation(annotation)
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
        cell.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        //各表示設定
        guard let caption = postData.caption, let baseLatitude = self.locationManager?.location?.coordinate.latitude, let baseLongitude = self.locationManager?.location?.coordinate.longitude, let targetLatitude = postData.location?.latitude, let targetLongitude = postData.location?.longitude, let name = postData.name else { return cell }
        //タイトル表示
        cell.captionLabel.text = caption
        //登録者名
        cell.registrationNameLabel.text = "登録者：" + name
        //現在地からの距離表示
        let baseLocation = CLLocation(latitude: baseLatitude, longitude: baseLongitude)
        //登録地
        let targetLocation = CLLocation(latitude: targetLatitude, longitude: targetLongitude)
        //距離
        let distance = baseLocation.distance(from: targetLocation)
        let meter = Int(distance * 1.09361)
        cell.distanceLabel.text = String(meter) + "m先"
        //FirebaseStorageから画像を取得
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        //一覧に画像表示
        cell.postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.postImageView.sd_setImage(with: imageRef)
        
        return cell
    }
    
    /// タップ時処理
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: IndexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postData = self.postDataReceived[indexPath.row]
        //FirebaseStorageから画像を取得
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        //AR画面に画像表示処理
        imageRef.getData(maxSize: 1 * 1024 * 1024) { (image, error) in
            if error != nil {
                return
            }
            let image = UIImage(data: image!)
            
            guard let cameraViewController = R.storyboard.camera.instantiateInitialViewController() else { return }
            cameraViewController.image = image
            self.present(cameraViewController, animated: true)
            print("DEBUG_PRINT: 撮影ボタンが押されました。")
        }
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
    
    /// 位置情報変更時処理
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - locations: [CLLocation]
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude

            print("Latitude:" + String(latitude) +  " Longitude:" + String(longitude))
        }
        //現在地から一定距離離れたら位置情報更新
        self.locationManager?.distanceFilter = 8.0
        self.locationUpDate()
        self.tableView.reloadData()
    }
}

//MARK: - MKMapViewDelegate

extension SpotListsViewController: MKMapViewDelegate {
    
    /// ピンの設定
    /// - Parameters:
    ///   - mapView: MKMapView
    ///   - annotation: MKAnnotation
    /// - Returns: annotationView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //現在地とピンを分ける
        if annotation is MKUserLocation {
            return nil
        }
        //MKPinAnnotationViewを宣言
        let annotationView = MKPinAnnotationView()
        //MKPinAnnotationViewのannotationにMKAnnotationのAnnotationを追加
        annotationView.annotation = annotation
        //ピンの色を設定
        annotationView.pinTintColor = .blue
        //注釈を設定
        annotationView.canShowCallout = true
        
        return annotationView
    }
}
