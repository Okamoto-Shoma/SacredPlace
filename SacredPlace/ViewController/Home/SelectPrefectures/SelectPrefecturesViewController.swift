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
    
    private var searchBar = UISearchBar()
    private let searchBarHeight: CGFloat = 44

    var postArray: [PostData] = []
    var filtArray: [PostData] = []
    
    //MARK: - outlet
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            //レイアウト調整
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 50, left: 0, bottom: 4, right: 0)
            layout.itemSize = CGSize(width: 180, height: 180)
            self.collectionView.collectionViewLayout = layout
            self.collectionView.backgroundColor = .black
            self.collectionView.contentOffset = CGPoint(x: 0, y: self.searchBarHeight)
        }
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupSearchBar()
        self.filtArray = self.postArray
        
    }
    
    //MARK: - PrivateMethod
    
    /// サーチバーの設定
    private func setupSearchBar() {
        self.searchBar.delegate = self
        self.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        self.collectionView.addSubview(self.searchBar)
        self.collectionView.backgroundColor = .black
        self.collectionView.tintColor = .black
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
        return self.filtArray.count
    }
    
    /// セル内容
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    /// - Returns: cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.selectPrefectures, for: indexPath) as! SelectPrefecturesCollectionViewCell
        let postData = self.filtArray[indexPath.row]
        //FirebaseStorageから画像を取得
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        //一覧に画像表示
        cell.collectionImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.collectionImageView.sd_setImage(with: imageRef)
        
        return cell
    }
    
    /// セル選択時
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postData = self.postArray[indexPath.row]
        guard let routeMapViewController = R.storyboard.routeMap.instantiateInitialViewController(), let caption = postData.caption, let latitude = postData.location?.latitude, let longitude = postData.location?.longitude else { return }
        routeMapViewController.latitude = latitude
        routeMapViewController.longitude = longitude
        routeMapViewController.caption = caption
        self.navigationController?.pushViewController(routeMapViewController, animated: true)
    }
}

//MARK: - UISearchBarDelegate

extension SelectPrefecturesViewController: UISearchBarDelegate {
    
    /// 検索ボタン押下時
    /// - Parameter searchBar: UISearchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let filt = self.postArray.filter { ($0.caption?.contains(self.searchBar.text!) ?? false) }
        self.filtArray = filt
        self.collectionView.reloadData()
    }
    
    /// テキスト内容変化時
    /// - Parameters:
    ///   - searchBar: UISearchBar
    ///   - searchText: String
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchBarText = self.searchBar.text, !searchBarText.isEmpty else {
            self.filtArray = self.postArray
            self.collectionView.reloadData()
            return
        }
    }
    
    /// キャンセル処理
    /// - Parameter searchBar: UISearchBar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.filtArray = self.postArray
        self.collectionView.reloadData()
    }
    
    /// サーチバータップ時
    /// - Parameter searchBar: UISearchBar
    /// - Returns: true
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.showsCancelButton = true
        return true
    }
}
