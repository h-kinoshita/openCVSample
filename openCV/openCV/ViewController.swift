//
//  ViewController.swift
//  openCV
//
//  Created by h.kinoshita on 2016/05/13.
//  Copyright © 2016年 mebro Inc. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    // セッション
    var mySession: AVCaptureSession!
    
    // カメラデバイス
    var myDevice: AVCaptureDevice!
    
    let detector = Detector()
    
    // 出力先
    var myOutput: AVCaptureVideoDataOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if initCamera() {
            // 撮影開始
            mySession.startRunning()
            
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initCamera() -> Bool {
        // セッションの作成
        mySession = AVCaptureSession()
        
        // 解像度の設定
        mySession.sessionPreset = AVCaptureSessionPresetMedium
        
        // バックカメラをmyDeviceに格納
        if let device = findCamera(AVCaptureDevicePosition.Front) {
            myDevice = device
        } else {
            print("カメラが見つかりませんでした")
            return false
        }
        
        do {
            // バックカメラからVideoInputを取得
            let myInput: AVCaptureDeviceInput?
            try myInput = AVCaptureDeviceInput(device: myDevice)
            
            // セッションに追加
            if mySession.canAddInput(myInput) {
                mySession.addInput(myInput)
            } else {
                return false
            }

            // 出力先を設定
            myOutput = AVCaptureVideoDataOutput()
            myOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA)]
            
            // FPS設定
            try myDevice.lockForConfiguration()
            myDevice.activeVideoMinFrameDuration = CMTimeMake(1, 15)
            myDevice.unlockForConfiguration()
            
            // デリゲードを設定
            let queue: dispatch_queue_t = dispatch_queue_create("myQuere", nil)
            myOutput.setSampleBufferDelegate(self, queue: queue)
            
            // 遅れてきたフレームは無視する
            myOutput.alwaysDiscardsLateVideoFrames = true
            
        } catch let error as NSError {
            print(error)
            return false
        }
        
        // セッションに追加
        if mySession.canAddOutput(myOutput) {
            mySession.addOutput(myOutput)
        } else {
            return false
        }
        
        // カメラの向きを合わせる
        for connection in myOutput.connections {
            if let conn = connection as? AVCaptureConnection {
                if conn.supportsVideoOrientation {
                    conn.videoOrientation = AVCaptureVideoOrientation.Portrait
                }
            }
        }
        return true
    }
    // 指定位置のカメラを探します
    func findCamera(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        for device in AVCaptureDevice.devices() {
            if(device.position == position){
                return device as? AVCaptureDevice
            }
        }
        return nil
    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)
    {
        dispatch_sync(dispatch_get_main_queue(), {
            
            let image = CameraUtil.imageFromSampleBuffer(sampleBuffer)
            
            // 顔認識
            let faceImage = self.detector.recognizeFace(image)
            
            // 表示
            self.imageView.image = faceImage
            
        })
    }
}

