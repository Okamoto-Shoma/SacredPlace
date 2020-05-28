//
//  TabBarController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/05/27.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase

class TabBarController: UITabBarController {
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        // Do any additional setup after loading the view.
        
        //タブアイコンの色
        self.tabBar.tintColor = UIColor(red: 1.0, green: 0.44, blue: 0.11, alpha: 1.0)
        //タブバーの背景色
        self.tabBar.barTintColor = UIColor(red: 0.96, green: 0.91, blue: 0.87, alpha: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            //ログインしてない時の処理
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController, animated: true, completion: nil)
        }
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

//MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    
    /// タブバー処理
    /// - Parameters:
    ///   - tabBarController: UITabBarController
    ///   - viewController: UIViewController
    /// - Returns: Bool
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is CameraViewController {
            //CameraViewControllerは、タブ切り替え時にタブバーを隠す
            if let cameraViewController = storyboard?.instantiateViewController(withIdentifier: "Camera") {
                //cameraViewController.modalPresentationStyle = .overFullScreen
                present(cameraViewController, animated: true)
                
                return false
            }
        }
        //その他のViewControllerは通常のタブ切り替え
        return true
    }
}
