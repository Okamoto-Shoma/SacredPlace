//
//  CreateAccountViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/05/28.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase


class CreateAccountViewController: UIViewController {
    
    //MARK: - Outlet
    
    @IBOutlet private var mailaddressTextField: UITextField!
    @IBOutlet private var userNameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.mailaddressTextField.resignFirstResponder()
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    //MARK: - Action
    
    /// アカウント作成ボタン
    /// - Parameter sender: UIButton
    @IBAction func handleCreateAccountButton(_ sender: UIButton) {
        if let address = self.mailaddressTextField.text, let password = self.passwordTextField.text, let userName = self.userNameTextField.text {
            //アドレスとパスワード表示のいずれかでも入力されていない時
            if address.isEmpty || password.isEmpty || userName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                return
            }
            //アドレスとパスワードでユーザー作成。
            Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
                guard error == nil else { return }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                //ユーザー名を設定
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = userName
                    changeRequest.commitChanges { error in
                        guard error == nil else { return }
                        print("DEBUG_PRINT: [userName = \(user.displayName!)の設定に成功しました。")
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    /// キャンセルボタン
    /// - Parameter sender: UIButton
    @IBAction func handleCancelButton(_ sender: UIButton) {
        guard let loginViewController = R.storyboard.self.login.instantiateInitialViewController() else { return }
        present(loginViewController, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
