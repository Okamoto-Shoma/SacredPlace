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
    
    @IBOutlet private var accountNametextField: UITextField!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Action
    
    /// アカウント名変更ボタン
    /// - Parameter sender: UIButton
    @IBAction func handleChangeName(_ sender: UIButton) {
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
        self.dismiss(animated: true, completion: nil)
    }
    
    /// キャンセルボタン
    /// - Parameter sender: UIButton
    @IBAction func handleCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
