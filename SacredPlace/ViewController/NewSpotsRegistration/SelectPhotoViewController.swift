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
    
    //MARK: - Aciton
    
    @IBAction func handleSelectButton(_ sender: UIButton) {
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SelectPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// 画像選択時処理
    /// - Parameters:
    ///   - picker: UIImagePickerController
    ///   - info: UIImagePickerController.InfoKey
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
            
        print("DEBUG_PRINT: image = \(image)")
        //画像確認画面に遷移
        let storyboard = UIStoryboard(name: "NewSpots", bundle: nil)
        guard let newSpotsViewController = storyboard.instantiateViewController(withIdentifier: "NewSpots") as? NewSpotsViewController else { return }
        newSpotsViewController.image = image
        picker.dismiss(animated: true, completion: nil)
        self.present(newSpotsViewController, animated: true, completion: nil)
    }
    
    /// 画面選択キャンセル処理
    /// - Parameter picker: UIImagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
