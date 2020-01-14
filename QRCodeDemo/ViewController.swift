//
//  ViewController.swift
//  QRCodeDemo
//
//  Created by xuanze on 2019/9/25.
//  Copyright © 2019 xuanze. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore
class ViewController: UIViewController {

    private var captureSession: AVCaptureSession!
    private var photoOutput:AVCapturePhotoOutput!
    private var metadataOutput: AVCaptureMetadataOutput!
    private var videoInput: AVCaptureDeviceInput!
    private var activeCamera: AVCaptureDevice! {
        return self.videoInput.device
    }
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var codeLayers = [String: [CAShapeLayer]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstSetup()
        self.setupPreviewLayer()
        if !self.captureSession.isRunning {
            DispatchQueue.global().async {
                self.captureSession.startRunning()
            }
        }
    }

    
    func firstSetup() {
        self.captureSession = AVCaptureSession()
        if self.captureSession.canSetSessionPreset(.vga640x480) {
            self.captureSession.sessionPreset = .vga640x480
        }
        
        if let videoDevice = AVCaptureDevice.default(for: .video) {
            do {
                videoInput = try AVCaptureDeviceInput(device: videoDevice)
            } catch {
                
            }
        }
        if self.captureSession.canAddInput(videoInput) {
            self.captureSession.addInput(videoInput)
        }
        
        if self.activeCamera.isAutoFocusRangeRestrictionSupported {
            do {
                try self.activeCamera.lockForConfiguration()
            } catch {
                print("activeCamera.lockForConfiguration error")
            }
            self.activeCamera.autoFocusRangeRestriction = .near
            //捕捉设备的自动对焦通常在任何距离都可以进行扫描
            //不过大部分条码距离都不远，所以可以缩小扫描区域来提升识别成功率
            self.activeCamera.unlockForConfiguration()
        }
        
        self.photoOutput = AVCapturePhotoOutput()
        if self.captureSession.canAddOutput(self.photoOutput) {
            self.captureSession.addOutput(self.photoOutput)
        }
        
        self.metadataOutput = AVCaptureMetadataOutput()
        if self.captureSession.canAddOutput(self.metadataOutput) {
            self.captureSession.addOutput(self.metadataOutput)
            
            self.metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.aztec]
            self.metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        }
    }
    
    private func setupPreviewLayer() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer.frame = self.view.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(self.previewLayer)
        self.view.layer.masksToBounds = true
    }

}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        self.didDetectCode(codes: metadataObjects)
    }
    
    func didDetectCode(codes: [AVMetadataObject]) {
        for code in codes {
            if let readableCode = code as? AVMetadataMachineReadableCodeObject {
                let stringValue = readableCode.stringValue
                //这个就是条形码的值
                //不过一般一次只有一个值，或者直接取第一个元素即为条码值
                print(stringValue)
            }
        }
    }
    
//    func didDetectCode(codes: [AVMetadataObject]) {
//        let transformCodes = self.transformedCodesFromCodes(codes: codes)
//        var lastCodes = [String]()
//        for codeStr in codeLayers.keys {
//            lastCodes.append(codeStr)
//        }
//
//        for transformCode in transformCodes {
//            if let code = transformCode as? AVMetadataMachineReadableCodeObject {
//                let str = code.stringValue
//                if let index = lastCodes.lastIndex(of: str!) {
//                    lastCodes.remove(at: index)
//                }
//
//                var layers = self.codeLayers[str!]
//                if layers == nil {
//                    layers = [self.makerBoundsLayer(), self.makerCornersLayer()]
//                    self.codeLayers[str!] = layers
//                    self.previewLayer.addSublayer(layers![0])
//                    self.previewLayer.addSublayer(layers![1])
//                }
//
//                let boundsLayer = layers![0]
//                boundsLayer.path = self.bezierPathForBounds(bounds: code.bounds).cgPath
//
//
//
//            }
//
//        }
//    }
//
//    func transformedCodesFromCodes(codes: [AVMetadataObject]) -> [AVMetadataObject]{
//        var transformdCodes = [AVMetadataObject]()
//
//        for code in codes {
//            if let transformCode = self.previewLayer.transformedMetadataObject(for: code) {
//                transformdCodes.append(transformCode)
//            }
//        }
//
//        return transformdCodes
//    }
//
//    func makerBoundsLayer() -> CAShapeLayer{
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.strokeColor = UIColor(red: 0.96, green: 0.75, blue: 0.06, alpha: 1.0).cgColor
//        shapeLayer.fillColor = nil
//        shapeLayer.lineWidth = 4.0
//        return shapeLayer
//    }
//
//    func makerCornersLayer() -> CAShapeLayer{
//        let cornerLayer = CAShapeLayer()
//        cornerLayer.lineWidth = 2.0
//        cornerLayer.strokeColor = UIColor(red: 0.172, green: 0.671, blue: 0.428, alpha: 1).cgColor
//        cornerLayer.fillColor = UIColor(red: 0.19, green: 0.753, blue: 0.489, alpha: 0.5).cgColor
//        return cornerLayer
//    }
//
//    func bezierPathForBounds(bounds: CGRect) -> UIBezierPath{
//        return UIBezierPath(rect: bounds)
//    }
//
//    func bezierPathForCorners(corners: [CGPoint]) {
//        let path = UIBezierPath()
//
//        for corner in corners {
//
//        }
//
//    }
    
//    func pointForCorner(corner: CGPoint) {
//        let dict = CGPDFDictionaryRef(
//        CGPoint(dictionaryRepresentation: )
//    }
}

