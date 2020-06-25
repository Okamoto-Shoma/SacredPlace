//
//  TabBarController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/05/27.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate {
        
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.delegate = self
        
        //タブアイコンの色
        self.tabBar.tintColor = UIColor(red: 1.0, green: 0.44, blue: 0.11, alpha: 1.0)
        //タブバーの背景色
        self.tabBar.barTintColor = .black
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            //ログインしてない時の処理
            guard let loginViewController = R.storyboard.login.instantiateInitialViewController() else { return }
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension TabBarController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// フォトライブラリ 設定
    /// - Parameters:
    ///   - picker: UIImagePickerController
    ///   - info: UIImagePickerController.InfoKey
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if info[.originalImage] != nil {
            //選択された画像を取得
            guard (info[.originalImage] as? UIImage) != nil else { return }
            }
    }
    
    /// キャンセル処理
    /// - Parameter picker: UIImagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
