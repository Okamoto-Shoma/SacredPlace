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
    
    //MARK: - Action
    
    /// アカウント作成ボタン
    /// - Parameter sender: UIButton
    @IBAction func handleCreateAccountButton(_ sender: UIButton) {
        
    }
    
    /// キャンセルボタン
    /// - Parameter sender: UIButton
    @IBAction func handleCancelButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "Login")
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
