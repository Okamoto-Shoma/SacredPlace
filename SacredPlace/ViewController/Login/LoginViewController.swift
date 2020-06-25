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
    
    @IBOutlet private var mailAddressTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

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
        if let address = self.mailAddressTextField.text, let password = self.passwordTextField.text {
            if address.isEmpty || password.isEmpty {
                return
            }
            
            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
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
