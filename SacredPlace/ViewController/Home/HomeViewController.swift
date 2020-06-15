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
    private var postList: [[PostData]] = []

    private var listener: ListenerRegistration?
    
    //MARK: - Outlet
    
    @IBOutlet private var collectionView: UICollectionView! {
        didSet {
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            //レイアウト調整
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            layout.itemSize = CGSize(width: 100, height: 100)
            self.collectionView.collectionViewLayout = layout
            self.collectionView.backgroundColor = .black
        }
    }
    
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.loginCheck()
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.collectionViewLayout.invalidateLayout()

    }
    
    //MARK: - PrivateMethod
    
    /// Firebaseからデータを取得
    func loginCheck() {
        if Auth.auth().currentUser != nil {
            //ログイン済
            if self.listener == nil {
                //listenerが未登録なら、登録してスナップショットを受信
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "caption", descending: false)
                self.listener = postsRef.addSnapshotListener() { (QuerySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                        return
                    }
                    //取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    self.postArray = QuerySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                    self.filtDate()
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
    private func filtDate() {
        //フィルター処理
        let filt: [String?] = self.postArray.map { $0.geocoder }
        self.postList.removeAll()
        if let filtArray = NSOrderedSet(array: filt as [Any]).array as? [String] {
            for position in filtArray {
                let post = self.postArray.filter { $0.geocoder == position }
                self.postList.append(post)
            }
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
        return self.postList.count
    }
    
    /// セル内容
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    /// - Returns: cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.collectionViewCell.identifier, for: indexPath) as! HomeCollectionViewCell
        cell.backgroundColor = .white
        cell.collectionLabel.text = self.postList[indexPath.row].first?.geocoder
        
        return cell
    }
    
    /// セル選択時処理
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectPrefecturesViewController = R.storyboard.selectPrefectures.instantiateInitialViewController() else { return }
        selectPrefecturesViewController.postArray = self.postList[indexPath.row]
        self.navigationController?.pushViewController(selectPrefecturesViewController, animated: true)
    }
}
