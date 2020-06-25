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
    
    @IBOutlet private var accountNametextField: UITextField! {
        didSet {
            self.accountNametextField.tintColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
            self.accountNametextField.textColor = .white
            self.accountNametextField.backgroundColor = .black
            self.accountNametextField.layer.cornerRadius = 10.0
            self.accountNametextField.text = Auth.auth().currentUser?.displayName
        }
    }
    @IBOutlet private var label: UILabel! {
        didSet {
            self.label.textColor = .white
        }
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(clickSaveTapped))
        self.navigationItem.setRightBarButton(saveButton, animated: true)
        self.view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)

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
}
