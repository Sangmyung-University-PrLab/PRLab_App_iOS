//
//  CameraStream.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/12.
//

import Foundation
import AVFoundation

final class CameraStream: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate{
    let frame: AsyncStream<CMSampleBuffer>
    
    override init() {
        var continuation: AsyncStream<CMSampleBuffer>.Continuation!
        frame = AsyncStream{
            continuation = $0
        }
        self.continuation = continuation
        super.init()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        continuation.yield(sampleBuffer)
    }
    
    //MARK: private
    private let continuation: AsyncStream<CMSampleBuffer>.Continuation
}
