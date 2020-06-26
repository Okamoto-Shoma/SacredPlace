//
//  LoginViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/05/28.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    //MARK: - Outlet
    
    @IBOutlet private var mailAddressTextField: UITextField! {
        didSet {
            self.mailAddressTextField.backgroundColor = .black
            self.mailAddressTextField.textColor = .white
            self.mailAddressTextField.tintColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
            self.mailAddressTextField.delegate = self
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
            self.mailAddressLabel.text = "メール"
            self.mailAddressLabel.textColor = .white
        }
    }
    @IBOutlet private var passwordLabel: UILabel! {
        didSet {
            self.passwordLabel.text = "パスワード"
            self.passwordLabel.textColor = .white
        }
    }
    @IBOutlet private var loginButton: UIButton! {
        didSet {
            self.loginButton.backgroundColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
            self.loginButton.layer.cornerRadius = 10.0
        }
    }
    @IBOutlet private var createAccountButton: UIButton! {
        didSet {
            self.createAccountButton.backgroundColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
            self.createAccountButton.layer.cornerRadius = 10.0
        }
    }
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        //プレースホルダー設定
        self.mailAddressTextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.mailAddressTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    //MARK: - Aciton
    
    /// ログイン処理
    /// - Parameter sender: UIButton
    @IBAction func handleLoginButton(_ sender: UIButton) {
        if let mailAddress = self.mailAddressTextField.text, let password = self.passwordTextField.text, !mailAddress.isEmpty || !password.isEmpty {
            if mailAddress.isEmpty || password.isEmpty {
                let alert = UIAlertController(title: "作成できません", message: "メールアドレス、パスワードまたは、全てが入力されていません", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "再入力", style: UIAlertAction.Style.cancel))
                self.present(alert, animated: true)
                print("DEBUG_PRINT: 何かが空文字です。")
                return
            }
            Auth.auth().signIn(withEmail: mailAddress, password: password) { authResult, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    let alert = UIAlertController(title: "ログインできません", message: "メールアドレス、パスワードまたは、両方が間違っています", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "再入力", style: UIAlertAction.Style.cancel))
                    self.present(alert, animated: true)
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /// アカウント作成処理
    /// - Parameter sender: UIButton
    @IBAction func handleCreateAccountButton(_ sender: UIButton) {
        guard let createAccountViewController = R.storyboard.self.createAccount.instantiateInitialViewController() else { return }
        self.present(createAccountViewController, animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    /// Returnボタン押下時
    /// - Parameter textField: UITextField
    /// - Returns: true
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.mailAddressTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        return true
    }
}

