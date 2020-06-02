//
//  PhotoViewController.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/06/02.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import AVFoundation

class PhotoViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var mainCamera: AVCaptureDevice?
    var innerCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewlayer: AVCaptureVideoPreviewLayer?
    
    //MARK: - Outlet
    @IBOutlet private var cameraImageView: UIImageView!
    @IBOutlet private var cameraButton: UIButton!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setupCaptureSession()
        self.setupDevice()
        self.setupInputOutpu()
        self.setupPreviewLayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.captureSession.startRunning()
        
    }
    
    //MARK: - Action
    
    @IBAction func handleCameraButton(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        guard let photoOutPut = self.photoOutput else { return }
        photoOutPut.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
    }
    
    //MARK: - PrivateMethod
    
    func setupCaptureSession() {
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                self.mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                self.innerCamera = device
            }
        }
        self.currentDevice = self.mainCamera
    }
    
    func setupInputOutpu() {
        do {
            guard let currentDevices = self.currentDevice else { return }
            guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevices) else { return }
            
            self.captureSession.addInput(captureDeviceInput)
            self.photoOutput = AVCapturePhotoOutput()
            guard let photoOutPut = self.photoOutput else { return }
            photoOutPut.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            self.captureSession.addOutput(photoOutPut)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        self.cameraPreviewlayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        guard let cameraPreviewLayers = self.cameraPreviewlayer else { return }
        cameraPreviewLayers.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayers.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayers.frame = self.cameraImageView.bounds
        self.cameraImageView.layer.insertSublayer(cameraPreviewLayers, at: 0)
    }
    
    func styleCaptureButton() {
        self.cameraButton.layer.borderColor = UIColor.white.cgColor
        self.cameraButton.layer.borderWidth = 5
        self.cameraButton.clipsToBounds = true
        self.cameraButton.layer.cornerRadius = min(self.cameraButton.frame.width, self.cameraButton.frame.height) / 2
    }
    
}

//MARK: AVCapturePhotoCaptureDelegate
extension PhotoViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let uiImage = UIImage(data: imageData)
            UIImageWriteToSavedPhotosAlbum(uiImage!, nil, nil, nil)
        }
    }
}
