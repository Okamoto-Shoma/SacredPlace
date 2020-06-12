//
//  SpotsListTableViewCell.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/06/01.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseUI

class SpotsListTableViewCell: UITableViewCell {
    
    var buttonTapAction: (() -> Void)?
    var title: String = ""
    var geocoder: String = ""
    var distance: Double?
    
    //MARK: - Outlet
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet private var captionLabel: UILabel!
    @IBOutlet private var distanceLabel: UILabel!
    @IBOutlet private var geocoderLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    
    //MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.captionLabel.text = self.title
        self.geocoderLabel.text = self.geocoder
        self.distanceLabel.text = "現在地からの距離：\(String(describing: self.distance!))"
        
    }
    
    //MARK: - Action
    
    @IBAction func handleCameraButton(_ sender: UIButton) {
        buttonTapAction?()
    }
}
