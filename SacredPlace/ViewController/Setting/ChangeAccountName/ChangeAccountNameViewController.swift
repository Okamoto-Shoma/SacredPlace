//
//  ChangeAccountNameViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/06/17.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase

class ChangeAccountNameViewController: UIViewController {
    
    //MARK: - Outlet
    
    @IBOutlet private var accountNametextField: UITextField!
    @IBOutlet private var label: UILabel!
    @IBOutlet private var unsubscribeButton: UIButton!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(clickSaveTapped))
        self.navigationItem.setRightBarButton(saveButton, animated: true)
        self.view.backgroundColor = .black
        self.label.textColor = .white
        self.accountNametextField.text = Auth.auth().currentUser?.displayName
        self.accountNametextField.textColor = .white
        self.accountNametextField.backgroundColor = .black
        self.accountNametextField.addBorderBottom(height: 1.0, color: .gray)
        self.unsubscribeButton.layer.cornerRadius = 10.0
        
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Action
    
    @objc private func clickSaveTapped() {
        if let accountName = self.accountNametextField.text {
            if accountName.isEmpty { return }
            //表示名を設定
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = accountName
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("DEBUG_PRINT:" + error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT:" + user.displayName!)
                }
            }
        }
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
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

//MARK: - UITextField

extension UITextField {
    
    /// ボタンボーダー設定
    /// - Parameters:
    ///   - height: CGFloat
    ///   - color: UIColor
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}
