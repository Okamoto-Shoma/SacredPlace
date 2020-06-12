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
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Action
    
    @IBAction func handleLogout(_ sender: UIButton) {
        //ログアウトする
        try? Auth.auth().signOut()
        //ログイン画面に戻る
        guard let loginViewController = R.storyboard.login.instantiateInitialViewController() else { return }
        present(loginViewController, animated: true, completion: nil)
        //ログイン画面から戻っていた問いのためにホーム画面を選択している状態
        tabBarController?.selectedIndex = 0
    }
}
