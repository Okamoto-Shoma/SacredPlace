//
//  SpotListsViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/05/28.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import MapKit
import CoreLocation

class SpotListsViewController: UIViewController {
    
    private var postArray: [PostData] = []
    // Firestoreのリスナー
    private var listener: ListenerRegistration!
    private var locationManager: CLLocationManager!
    
    //MARK: - Outlet
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    @IBOutlet private var mapView: MKMapView!
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.congigurationSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startUpdatingLocation()
        
        if Auth.auth().currentUser != nil {
            //ログイン済
            if self.listener == nil {
                //listenerが未登録なら、登録してスナップショットを受信
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
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
                    }
                    //TableViewの表示を更新
                    self.tableView.reloadData()
                }
            }
        } else {
            //未ログイン
            if self.listener != nil {
                //listener登録済なら削除してpostArrayをクリア
                self.listener.remove()
                self.listener = nil
                self.postArray = []
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - PrivateMethod
    
    private func startUpdatingLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
        self.locationManager.startUpdatingLocation()
    }
    
    private func congigurationSubviews() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        //カスタムセルの登録
        self.tableView.register(R.nib.self.spotsListTableViewCell)
        //現在地
        self.mapView.setCenter(self.mapView.userLocation.coordinate, animated: true)
        self.mapView.userTrackingMode = MKUserTrackingMode.follow
        //マップタイプ
        self.mapView.mapType = .standard
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
        return self.postArray.count
    }
    
    /// セル内容
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: IndexPath
    /// - Returns: cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SpotCells", for: indexPath) as! SpotsListTableViewCell
        cell.setPostData(self.postArray[indexPath.row])
        
        let post = self.postArray[indexPath.row]
        if let caption = post.caption, let latitude = post.location?.latitude, let longitude = post.location?.longitude {
            let point = MKPointAnnotation()
            point.title = caption
            point.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.mapView.addAnnotation(point)
            print("DEBUG_PRINT: \(caption)")
            print("DEBUG_PRINT: \(latitude)")
            print("DEBUG_PRINT: \(longitude)")
        }
        
        return cell
    }
    
    /// タップ時処理
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: IndexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postData = self.postArray[indexPath.row]
        
        guard let latitude = postData.location?.latitude, let longitude = postData.location?.longitude, let geocoder = postData.geocoder else { return }
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: center, span: span)
        self.mapView.setRegion(region, animated: true)
        
        print("DEBUG_PRINT: \(geocoder)")
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
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            print("DEBUG_PRINT: 位置情報取得が許可されました。")
            locationManager.startUpdatingLocation()
        case .denied:
            print("DEBUG_PRINT: 位置情報取得が拒否されました。")
        default:
            print("DEBUG_PRINT: 位置情報を許可してください。")
        }
    }
}
