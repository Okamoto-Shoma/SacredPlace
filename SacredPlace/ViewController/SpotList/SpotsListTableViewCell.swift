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
    
    @IBOutlet private var postImageView: UIImageView!
    @IBOutlet private var captionLabel: UILabel!
    @IBOutlet private var latitudeLabel: UILabel!
    @IBOutlet private var longitudeLabel: UILabel!
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
        
    }
    
    //MARK: - Action
    
    @IBAction func handleCameraButton(_ sender: UIButton) {
    }
    
    //MARK: - PrivateMethod
    
    /// - Parameter postData: PostData
    func setPostData(_ postData: PostData) {
        self.postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        self.postImageView.sd_setImage(with: imageRef)
        
        guard let caption = postData.caption, let latitude = postData.location?.latitude, let longitude = postData.location?.longitude, let geocoder = postData.geocoder else { return }
        //キャプション表示
        self.captionLabel.text =  "\(caption)"
        //緯度/経度表示
        self.latitudeLabel.text = "緯度：\(latitude)"
        self.longitudeLabel.text = "経度：\(longitude)"
        //都道府県表示
        self.geocoderLabel.text = "登録地：\(geocoder)"
        //画像表示
    }
}
