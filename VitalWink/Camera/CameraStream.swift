//
//  CameraStream.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/12.
//

import Foundation
import AVFoundation

final class CameraStream: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate{
    private weak var delegate: CameraStreamDelegate?
    
    init(delegate: CameraStreamDelegate? = nil) {
        self.delegate = delegate
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.frameContinuation.yield(sampleBuffer)
    }
}
