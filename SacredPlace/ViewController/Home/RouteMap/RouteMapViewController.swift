//
//  RouteMapViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/06/15.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import MapKit

class RouteMapViewController: UIViewController {
    
    var latitude: Double?
    var longitude: Double?

    //MARK: - Outlet
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.pinMap()
    }

    //MARK: - PrivateMethod
    
    private func pinMap() {
        let center = CLLocationCoordinate2D(latitude: self.latitude ?? 0, longitude: self.longitude ?? 0)
        self.mapView.setCenter(center, animated: true)
        let mySpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let myRegion = MKCoordinateRegion(center: center, span: mySpan)
        self.mapView.region = myRegion
        self.view.addSubview(self.mapView)
        
        let myPin = MKPointAnnotation()
        myPin.coordinate = center
        self.mapView.addAnnotation(myPin)
    }

}
