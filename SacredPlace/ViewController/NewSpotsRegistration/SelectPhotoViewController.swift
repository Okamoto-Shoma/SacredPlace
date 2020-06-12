//
//  SelectPhotoViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/05/29.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit

class SelectPhotoViewController: UIViewController {
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showPhotoLibrary()
    }
    
    //MARK: - PrivateMethod
    
    private func showPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            pickerController.modalPresentationStyle = .overFullScreen
            self.present(pickerController, animated: true, completion: nil)
        }
    }
}

extension SelectPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// 画像選択時処理
    /// - Parameters:
    ///   - picker: UIImagePickerController
    ///   - info: UIImagePickerController.InfoKey
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage, let cameraViewController = R.storyboard.camera.instantiateInitialViewController() else { return }
        //画像確認画面に遷移
        cameraViewController.image = image
        picker.dismiss(animated: true, completion: nil)
        self.present(cameraViewController, animated: true, completion: nil)
        self.tabBarController?.selectedIndex = 0
    }
    
    /// 画面選択キャンセル処理
    /// - Parameter picker: UIImagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.tabBarController?.selectedIndex = 0
    }
}
