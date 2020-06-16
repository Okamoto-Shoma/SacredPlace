//
//  RouteMapViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/06/15.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import MapKit

class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle: String, pinSubTitle: String, location: CLLocationCoordinate2D) {
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
    }
}

class RouteMapViewController: UIViewController {
    
    var latitude: Double?
    var longitude: Double?
    var caption: String?
    private var locationManager: CLLocationManager?
    
    //MARK: - Outlet
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startUpdatingLocation()
        self.pinMap()
    }
    
    //MARK: - PrivateMethod

    /// ルート案内
    private func pinMap() {
        //マップの表示域設定
        //登録地を設定
        let base = CLLocationCoordinate2D(latitude: self.locationManager?.location?.coordinate.latitude ?? 0, longitude: self.locationManager?.location?.coordinate.longitude ?? 0)
        let target = CLLocationCoordinate2D(latitude: self.latitude ?? 0, longitude: self.longitude ?? 0)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: target, span: span)
        self.mapView.setRegion(region, animated: true)
        //登録地にピンを立てる
        let targetPin = customPin(pinTitle: self.caption!, pinSubTitle: "", location: target)
        self.mapView.addAnnotation(targetPin)
        //現在地から登録地までのルートに線を引く
        let basePlaceMark = MKPlacemark(coordinate: base)
        let targetPlaceMark = MKPlacemark(coordinate: target)
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: basePlaceMark)
        directionRequest.destination = MKMapItem(placemark: targetPlaceMark)
        //交通手段を車にする
        directionRequest.transportType = .automobile
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionsResponse = response else {
                if error != nil {
                    print("We have error getting directions")
                }
                return
            }
            let route = directionsResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
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
}

//MARK: - MKMapViewDelegate

extension RouteMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 5.0
        renderer.strokeColor = .red
        return renderer
    }
}

//MARK: -CLLocationManagerDelegate

extension RouteMapViewController: CLLocationManagerDelegate {
    
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
}
