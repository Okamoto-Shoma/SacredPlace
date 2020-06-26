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
        
    @IBOutlet private var mailaddressTextField: UITextField! {
        didSet {
            self.mailaddressTextField.backgroundColor = .black
            self.mailaddressTextField.textColor = .white
            self.mailaddressTextField.tintColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
            self.mailaddressTextField.delegate = self
        }
    }
    @IBOutlet private var userNameTextField: UITextField! {
        didSet {
            self.userNameTextField.backgroundColor = .black
            self.userNameTextField.textColor = .white
            self.userNameTextField.tintColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
            self.userNameTextField.delegate = self
        }
    }
    @IBOutlet private var passwordTextField: UITextField! {
        didSet {
            self.passwordTextField.backgroundColor = .black
            self.passwordTextField.textColor = .white
            self.passwordTextField.tintColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
            self.passwordTextField.delegate = self
        }
    }
    @IBOutlet private var mailAddressLabel: UILabel! {
        didSet {
            self.mailAddressLabel.textColor = .white
        }
    }
    @IBOutlet private var passwordLabel: UILabel! {
        didSet {
            self.passwordLabel.textColor = .white
        }
    }
    @IBOutlet private var userNameLabel: UILabel! {
        didSet {
            self.userNameLabel.textColor = .white
        }
    }
    @IBOutlet private var createAccountButton: UIButton! {
        didSet {
            self.createAccountButton.backgroundColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
            self.createAccountButton.layer.cornerRadius = 10.0
        }
    }
    @IBOutlet private var cancelButton: UIButton! {
        didSet {
            self.cancelButton.backgroundColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
            self.cancelButton.layer.cornerRadius = 10.0
        }
    }
    
    
    
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        //self.view.backgroundColor = .black
        //プレースホルダー設定
        self.mailaddressTextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        self.userNameTextField.attributedPlaceholder = NSAttributedString(string: "ユーザー名", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
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
                let alert = UIAlertController(title: "作成できません", message: "メールアドレス、ユーザー名、パスワードまたは、全てが入力されていません", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "再入力", style: UIAlertAction.Style.cancel))
                self.present(alert, animated: true)
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
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate

extension CreateAccountViewController: UITextFieldDelegate {
    
    /// Return押下時処理
    /// - Parameter textField: UITextField
    /// - Returns: true
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.mailaddressTextField.resignFirstResponder()
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        return true
    }
}
