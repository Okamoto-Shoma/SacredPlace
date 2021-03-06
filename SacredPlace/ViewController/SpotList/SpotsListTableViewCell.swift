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
    
    //MARK: - Outlet
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel! {
        didSet {
            self.captionLabel.textColor = .black
        }
    }
    @IBOutlet weak var distanceLabel: UILabel! {
        didSet {
            self.distanceLabel.textColor = .black
        }
    }
    @IBOutlet weak var registrationNameLabel: UILabel! {
        didSet {
            self.registrationNameLabel.textColor = .black
        }
    }
    
    //MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
