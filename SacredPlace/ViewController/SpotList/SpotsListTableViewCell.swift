//
//  SpotsListTableViewCell.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/06/01.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import FirebaseUI
import CoreLocation
import MapKit

class SpotsListTableViewCell: UITableViewCell {
    
    //MARK: - Outlet
    
    @IBOutlet private var postImageView: UIImageView!
    @IBOutlet private var captionLabel: UILabel!
    @IBOutlet private var latitudeLabel: UILabel!
    @IBOutlet private var longitudeLabel: UILabel!
    
    
    //MARK: - LifeCycle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - PrivateMethod
    
    /// 画像を設定
    /// - Parameter postData: PostData
    func setPostData(_ postData: PostData) {
        //画像の表示
        self.postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        self.postImageView.sd_setImage(with: imageRef)
        
        //キャプションの表示
        self.captionLabel.text = "\(postData.name!): \(postData.caption!)"
        
        guard let latitude = postData.location?.latitude else { return }
        guard let longitude = postData.location?.longitude else { return }
        //緯度/経度表示
        self.latitudeLabel.text = "緯度：\(latitude)"
        self.longitudeLabel.text = "経度：\(longitude)"
    }
}
