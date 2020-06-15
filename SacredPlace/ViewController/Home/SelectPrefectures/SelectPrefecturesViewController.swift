//
//  SelectPrefecturesViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/06/11.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import FirebaseUI


class SelectPrefecturesViewController: UIViewController {
    
    var postArray: [PostData] = []
    
    //MARK: - outlet
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            //レイアウト調整
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            layout.itemSize = CGSize(width: 170, height: 170)
            self.collectionView.collectionViewLayout = layout
        }
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension SelectPrefecturesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// セル数
    /// - Parameters:
    ///   - collectionView: UICollectionVIew
    ///   - section: Int
    /// - Returns: self.filtArray.count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postArray.count
    }
    
    /// セル内容
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    /// - Returns: cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.selectPrefectures, for: indexPath) as! SelectPrefecturesCollectionViewCell
        let postData = self.postArray[indexPath.row]
        cell.backgroundColor = .blue
        cell.collectionLabel.text = postData.caption
        //FirebaseStorageから画像を取得
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        //一覧に画像表示
        cell.collectionImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.collectionImageView.sd_setImage(with: imageRef)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postData = self.postArray[indexPath.row]
        guard let routeMapViewController = R.storyboard.routeMap.instantiateInitialViewController(), let latitude = postData.location?.latitude, let longitude = postData.location?.longitude else { return }
        routeMapViewController.latitude = latitude
        routeMapViewController.longitude = longitude
        self.navigationController?.pushViewController(routeMapViewController, animated: true)
        
    }
}
