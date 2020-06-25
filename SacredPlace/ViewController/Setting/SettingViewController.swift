//
//  SettingViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/05/28.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    //MARK: - Outlet
    
    @IBOutlet private var accountChangeButton: UIButton!
    @IBOutlet private var logoutButton: UIButton!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.view.backgroundColor = .black
        
        self.accountChangeButton.layer.cornerRadius = 10.0
        self.logoutButton.layer.cornerRadius = 10.0

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Action
    
    /// ログアウトボタン
    /// - Parameter sender: UIButton
    @IBAction func handleLogout(_ sender: UIButton) {
        let alert = UIAlertController(title: "ログアウト", message: "ログアウトしますか？", preferredStyle: UIAlertController.Style.alert)
        //キャンセル
        alert.addAction(UIAlertAction(title: "いいえ", style: UIAlertAction.Style.cancel) {(action: UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        })
        //ログアウト
        alert.addAction(UIAlertAction(title: "はい", style: UIAlertAction.Style.default) {(action: UIAlertAction) in
            try? Auth.auth().signOut()
            //ログイン画面に戻る
            guard let loginViewController = R.storyboard.login.instantiateInitialViewController() else { return }
            self.present(loginViewController, animated: true, completion: nil)
            //ログイン画面から戻っていた時のためにホーム画面を選択している状態
            self.tabBarController?.selectedIndex = 0
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    /// アカウント名変更ボタン
    /// - Parameter sender: UIButton
    @IBAction func handleNameChanege(_ sender: UIButton) {
        guard let changeAccountNameViewController = R.storyboard.chanegeAccountName.instantiateInitialViewController() else { return }
        changeAccountNameViewController.title = "プロフィール編集"
        self.navigationController?.pushViewController(changeAccountNameViewController, animated: true)
    }
}
