//
//  HomeViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/05/27.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class HomeViewController: UIViewController {
    
    private var postArray: [PostData] = []
    private var divideArray: [[PostData]] = []
    private var collectionDisplayImages: [Any?] = []
    private var listener: ListenerRegistration?
        
    //MARK: - Outlet
    
    @IBOutlet private var collectionView: UICollectionView! {
        didSet {
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            //レイアウト調整
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
            layout.itemSize = CGSize(width: 178, height: 240)
            self.collectionView.collectionViewLayout = layout
            self.collectionView.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
            self.collectionView.register(R.nib.homeCollectionViewCell)
        }
    }
    
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loginCheck()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: - PrivateMethod

    /// Firebaseからデータを取得
    private func loginCheck() {
        if Auth.auth().currentUser != nil {
            //ログイン済
            if self.listener == nil {
                //listenerが未登録なら、登録してスナップショットを受信
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "geocoder", descending: false)
                self.listener = postsRef.addSnapshotListener() { (QuerySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                        return
                    }
                    //取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    self.postArray = QuerySnapshot!.documents.map { document in
                        //print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                    self.filtData()
                }
            } else {
                //未ログイン
                if self.listener != nil {
                    //listener登録済なら削除してpostArrayをクリア
                    self.listener?.remove()
                    self.listener = nil
                    self.postArray = []
                }
                self.collectionView.reloadData()
            }
        }
    }

    /// データをフィルター処理
    private func filtData() {
        //フィルター処理
        let divideGeocoder: [String?] = self.postArray.map { $0.geocoder }
        self.divideArray.removeAll()
        if let filtArray = NSOrderedSet(array: divideGeocoder as [Any]).array as? [String] {
            for position in filtArray {
                let post = self.postArray.filter { $0.geocoder == position }
                self.divideArray.append(post)
            }
        }
        self.collectionDisplayImages = self.divideArray.map {
            guard let id = $0.first?.id else { return nil }
            return Storage.storage().reference().child(Const.ImagePath).child(id + ".jpg")
        }
        self.collectionView.reloadData()
    }
}

//MARK: - UICollectionViewDelegate, UICollectionVIewDataSource

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// セル数
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - section: Int
    /// - Returns: self.prefectures.count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return self.prefectures.count
        return self.divideArray.count
    }
    
    /// セル内容
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    /// - Returns: cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.homeCollectionViewCell, for: indexPath)!
        let countData = self.divideArray[indexPath.row].count
        cell.prefecturesLabel.text = self.divideArray[indexPath.row].first?.geocoder
        cell.registrationCountLabel.text = String(countData)
        cell.prefecturesLabel.textColor = .white
        cell.registrationCountLabel.textColor = .gray
        //一覧に画像表示
        cell.ImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        if let image = self.collectionDisplayImages[indexPath.row] as? StorageReference {
           cell.ImageView.sd_setImage(with: image)
        }
        return cell
    }
    
    /// セル選択時処理
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectPrefecturesViewController = R.storyboard.selectPrefectures.instantiateInitialViewController() else { return }
        selectPrefecturesViewController.postArray = self.divideArray[indexPath.row]
        selectPrefecturesViewController.title = self.divideArray[indexPath.row].first?.geocoder
        self.navigationController?.pushViewController(selectPrefecturesViewController, animated: true)
    }
}
