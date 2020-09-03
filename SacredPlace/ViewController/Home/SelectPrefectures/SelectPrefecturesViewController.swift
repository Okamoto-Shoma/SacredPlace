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
    private var divideArray: [PostData] = []
    private var images: [Any?] = []

    
    //MARK: - outlet
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            //レイアウト調整
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 50, left: 0, bottom: 4, right: 0)
            layout.itemSize = CGSize(width: 178, height: 240)
            self.collectionView.collectionViewLayout = layout
            self.collectionView.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
            self.collectionView.contentOffset = CGPoint(x: 0, y: self.searchBarHeight)
            self.collectionView.register(R.nib.selectPrefecturesCollectionViewCell)
        }
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupSearchBar()
        self.divideArray = self.postArray
        self.getImage()
        self.view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
    }
    
    //MARK: - PrivateMethod
    
    /// サーチバーの設定
    private func setupSearchBar() {
        self.searchBar.delegate = self
        self.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        self.searchBar.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        self.searchBar.tintColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
        self.searchBar.barTintColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        self.searchBar.searchTextField.textColor = .white
        self.collectionView.addSubview(self.searchBar)
    }
    
    /// 画像取得設定
    private func getImage() {
        self.images = self.divideArray.map {
            let id = $0.id
            return Storage.storage().reference().child(Const.ImagePath).child(id + ".jpg")
        }
        self.collectionView.reloadData()
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
        return self.divideArray.count
    }
    
    /// セル内容
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    /// - Returns: cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.selectPrefecturesCollectionViewCell, for: indexPath)!
        let postData = self.divideArray[indexPath.row]
        //文字の色設定
        cell.captionLabel.textColor = .white
        cell.registrationDateLabel.textColor = .gray
        //表示設定
        cell.captionLabel.text = postData.caption
        cell.registrationDateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: date)
            cell.registrationDateLabel.text = dateString
        }
        //画像表示
        cell.ImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        if let image = self.images[indexPath.row] as? StorageReference {
           cell.ImageView.sd_setImage(with: image)
        }
        
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
        self.divideArray = self.postArray.filter { ($0.caption?.contains(self.searchBar.text!) ?? false) }
        self.getImage()
        self.collectionView.reloadData()
    }
    
    /// テキスト内容変化時
    /// - Parameters:
    ///   - searchBar: UISearchBar
    ///   - searchText: String
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchBarText = self.searchBar.text, !searchBarText.isEmpty else {
            self.divideArray = self.postArray
            self.getImage()
            self.collectionView.reloadData()
            return
        }
    }
    
    /// キャンセル処理
    /// - Parameter searchBar: UISearchBar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.divideArray = self.postArray
        self.getImage()
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
