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
    
    //MARK: - Aciton
    
    /// ログイン処理
    /// - Parameter sender: UIButton
    @IBAction func handleLoginButton(_ sender: UIButton) {
        
    }
    
    /// アカウント作成処理
    /// - Parameter sender: UIButton
    @IBAction func handleCreateAccountButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "CreateAccount", bundle: nil)
        let createAccountViewController = storyboard.instantiateViewController(withIdentifier: "Create")
        self.present(createAccountViewController, animated: true, completion: nil)
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
