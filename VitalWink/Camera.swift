//
//  Camera.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/08.
//

import Foundation
import AVFoundation
import Combine

final class Camera: NSObject{
    public private(set) var position: Position = .front
    let frameObserver = PassthroughSubject<CMSampleBuffer, Never>()
    
    init(completionHandler: @escaping (Error?) -> Void){
        let cameras = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices
        
        guard !cameras.isEmpty else{
            completionHandler(CameraError.notFoundCamera)
            self.frontCamera = nil
            self.backCamera = nil
            super.init()
            return
        }
        
        frontCamera = cameras.first(where: {$0.position == .front})
        backCamera = cameras.first(where: {$0.position == .back})
        super.init()
        self.setUp(completionHandler: completionHandler)
    }
    func start(){
        self.sessionQueue.async {
            if !self.captureSession.isRunning{
                self.captureSession.startRunning()
            }
        }
    }
    func stop(){
        self.sessionQueue.async {
            if self.captureSession.isRunning{
                self.captureSession.stopRunning()
            }
        }
    }
    
    func changeCameraPosition() throws{
        captureSession.beginConfiguration()
        let camera: AVCaptureDevice
        switch position {
        case .front:
            camera = backCamera
            self.position = .back
        case .back:
            camera = frontCamera
            self.position = .front
        }
        captureSession.removeInput(videoDeviceInput)
        do{
            videoDeviceInput = try AVCaptureDeviceInput(device: camera)
        }catch{
            captureSession.commitConfiguration()
            throw error
        }
        if captureSession.canAddInput(videoDeviceInput){
            captureSession.addInput(videoDeviceInput)
        }
        captureSession.commitConfiguration()
    }
    enum CameraError: Error, LocalizedError{
        case notHavePermission
        case notFoundCamera
        
        var errorDescription: String?{
            switch self{
            case .notFoundCamera:
                return "카메라를 찾을 수 없습니다."
            case .notHavePermission:
                return "카메라 권한이 없습니다."
            }
        }
    }
    enum Position {
    case front,back
    }
    
    //MARK: - private
    private func isHaveCameraPermission() -> Bool{
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            return true
        default:
            return false
        }
    }
    private func requestCameraPermission(completionHandler: @escaping (Bool) -> Void ){
        AVCaptureDevice.requestAccess(for: .video){
            completionHandler($0)
        }
    }
    
    private func setUp(completionHandler: @escaping (Error?) -> Void) {
        guard isHaveCameraPermission() else{
            requestCameraPermission{
                if !$0{
                    completionHandler(CameraError.notHavePermission)
                }
            }
            return
        }
        
        self.captureSession.sessionPreset = .photo
        self.captureSession.beginConfiguration()
        do{
            self.videoDeviceInput = try AVCaptureDeviceInput(device: frontCamera)
            
            if self.captureSession.canAddInput(self.videoDeviceInput){
                self.captureSession.addInput(self.videoDeviceInput)
            }else{
                self.captureSession.commitConfiguration()
                return
            }
            
            self.captureSession.sessionPreset = AVCaptureSession.Preset.high
            self.videoOutput.videoSettings = [
                (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
            ]
            self.videoOutput.alwaysDiscardsLateVideoFrames = true
            self.videoOutput.setSampleBufferDelegate(self, queue: captureQueue)
            
            if self.captureSession.canAddOutput(self.videoOutput){
                self.captureSession.addOutput(self.videoOutput)
            }
            
            else{
                self.captureSession.commitConfiguration()
                return
            }
            self.captureSession.commitConfiguration()
        }catch{
            completionHandler(error)
        }
    }
    private let frontCamera: AVCaptureDevice!
    private let backCamera: AVCaptureDevice!
    private let sessionQueue = DispatchQueue(label: "session Queue")
    private let captureQueue = DispatchQueue(label: "capture Queue")
    
    //MARK: - 카메라 관련 변수
    private let captureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput!
    private let videoOutput = AVCaptureVideoDataOutput()

}

extension Camera:AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.frameObserver.send(sampleBuffer)
    }
}
