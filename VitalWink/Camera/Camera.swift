//
//  Camera.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/08.
//

import Foundation
import AVFoundation
import Combine
import Dependencies
import ComposableArchitecture

final class Camera: CameraStreamDelegate{
    public private(set) var position: Position = .front
    @Published public private(set) var frame: CMSampleBuffer! = nil
    
    init(){
        let cameras = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices
        
        frontCamera = cameras.first(where: {$0.position == .front})
        backCamera = cameras.first(where: {$0.position == .back})
    }
    
    @MainActor
    func getFrame(_ frame: CMSampleBuffer) async{
        await Task.yield()
        self.frame = frame
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
        guard let videoDeviceInput = videoDeviceInput else{
            return
        }
        
        let camera: AVCaptureDevice!
        switch position {
        case .front:
            camera = backCamera
            self.position = .back
        case .back:
            camera = frontCamera
            self.position = .front
        }
        guard camera != nil else{
            throw CameraError.notFoundCamera
        }
        
        captureSession.removeInput(videoDeviceInput)
        do{
            try setVideoDeviceInput(camera: camera)
        }catch{
            throw error
        }
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
    
    private func setUp() async throws{
        do{
            if isHaveCameraPermission(){
                try setCaptureSession()
            }
            else{
              if await AVCaptureDevice.requestAccess(for: .video){
                    try setCaptureSession()
               }else{
                    throw CameraError.notHavePermission
               }
            }
        }catch{
            throw error
        }
    }
    
    private func setCaptureSession() throws{
        captureSession.sessionPreset = .photo
        captureSession.beginConfiguration()
        do{
            try setVideoDeviceInput(camera: frontCamera)
            captureSession.sessionPreset = AVCaptureSession.Preset.high
            videoOutput.videoSettings = [
                (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
            ]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(cameraStream, queue: captureQueue)
            
            if self.captureSession.canAddOutput(videoOutput){
                self.captureSession.addOutput(videoOutput)
            }
            else{
                captureSession.commitConfiguration()
                return
            }
            captureSession.commitConfiguration()
        }catch{
            throw error
        }
    }
    private func setVideoDeviceInput(camera: AVCaptureDevice) throws{
        do{
            videoDeviceInput = try AVCaptureDeviceInput(device: camera)
        }catch{
            throw error
        }
        
        if captureSession.canAddInput(videoDeviceInput!){
            captureSession.addInput(videoDeviceInput!)
        }else{
            captureSession.commitConfiguration()
            return
        }
    }
    private let frontCamera: AVCaptureDevice!
    private let backCamera: AVCaptureDevice!
    private let sessionQueue = DispatchQueue(label: "session Queue")
    private let captureQueue = DispatchQueue(label: "capture Queue")
    
    //MARK: - 카메라 관련 변수
    private let captureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let videoOutput = AVCaptureVideoDataOutput()
    private lazy var cameraStream = CameraStream(delegate: self)
}

