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
    
    @IBOutlet private var accountChangeButton: UIButton! {
        didSet {
            self.accountChangeButton.layer.cornerRadius = 10.0
            self.accountChangeButton.backgroundColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
        }
    }
    @IBOutlet private var logoutButton: UIButton! {
        didSet {
            self.logoutButton.layer.cornerRadius = 10.0
            self.logoutButton.backgroundColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
        }
    }
    @IBOutlet private var unsubscribeButton: UIButton! {
        didSet {
            self.unsubscribeButton.layer.cornerRadius = 10.0
            self.unsubscribeButton.backgroundColor = .lightGray
        }
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)

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
    
    /// 退会ボタン
    /// - Parameter sender: UIButton
    @IBAction func handleUnsubscribe(_ sender: UIButton) {
        var alertTextField: UITextField!
        //退会確認アラート処理
        let checkAlert = UIAlertController(title: "退会",message: "本当に退会しますか？",preferredStyle: UIAlertController.Style.alert)
        //キャンセル処理
        checkAlert.addAction(UIAlertAction(title: "いいえ", style: UIAlertAction.Style.cancel) {(action: UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        })
        //退会実行処理
        checkAlert.addAction(UIAlertAction(title: "はい", style: UIAlertAction.Style.default) {(action: UIAlertAction) in
            //パスワード確認処理
            let executionAlert = UIAlertController(title: "退会処理", message: "登録アドレスを入力してください", preferredStyle: UIAlertController.Style.alert)
            //入力画面
            executionAlert.addTextField(configurationHandler: {(textField: UITextField!) in
                alertTextField = textField
            })
            //キャンセル
            executionAlert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel) {(action: UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            })
            //実行処理
            executionAlert.addAction(UIAlertAction(title: "退会", style: UIAlertAction.Style.default) {(action: UIAlertAction) in
                //パスワードが正しいか判定
                guard let user = Auth.auth().currentUser else { return }
                let email = user.email
                if alertTextField.text == email {
                    Auth.auth().currentUser?.delete {(error) in
                        if error == nil {
                            print("DEBUG_PRINT: 退会に成功しました。")
                            //ログイン画面に戻る
                            guard let loginViewController = R.storyboard.login.instantiateInitialViewController() else { return }
                            self.present(loginViewController, animated: true, completion: nil)
                            //ログイン画面から戻っていた時のためにホーム画面を選択している状態
                            self.tabBarController?.selectedIndex = 0
                        } else {
                            print("DEBUG_PRINT: \(String(describing: error?.localizedDescription))")
                        }
                    }
                } else {
                    print("DEBUG_PRINT: 入力されたアドレスが違います")
                    let backAlert = UIAlertController(title: "入力されたアドレスが違います", message: "", preferredStyle: UIAlertController.Style.alert)
                    backAlert.addAction(UIAlertAction(title: "再度入力", style: UIAlertAction.Style.default) {(action: UIAlertAction) in
                        self.present(executionAlert, animated: true, completion: nil)
                    })
                    self.present(backAlert, animated: true, completion: nil)
                }
            })
            self.present(executionAlert, animated: true, completion: nil)
        })
        self.present(checkAlert, animated: true, completion: nil)
    }
}
