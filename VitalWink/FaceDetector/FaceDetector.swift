//
//  FaceDetector.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/08.
//

import Foundation
import Vision
import UIKit
import CoreGraphics
import Accelerate
import Dependencies
public final class FaceDetector{
    enum FaceDetectorError: LocalizedError{
        case getEmptyUIImage
        var errorDescription: String?{
            switch self{
            case .getEmptyUIImage:
                return "빈 UIImage를 받았습니다."
            }
        }
    }
    
    public func detect(_ image: UIImage) async throws -> CGRect{
        guard let cgImage = image.cgImage else{
            throw FaceDetectorError.getEmptyUIImage
        }
        let handler = VNImageRequestHandler(cgImage: cgImage,orientation: .leftMirrored)
        
        return try await withCheckedThrowingContinuation{continuation in
            if trackRequest == nil{
                let request = makeFaceDetectionRequset(continuation: continuation, size: image.size)
                DispatchQueue.global(qos:.utility).async {
                    do{
                        try handler.perform([request])
                    }
                    catch{
                        continuation.resume(throwing: error)
                    }
                }
            }
            else{
                do{
                    let bbox = try self.track(buffer: image.cvPixelBuffer!)
                    let normBbox = VNImageRectForNormalizedRect(bbox, Int(image.size.width), Int(image.size.height))
                        .applying(self.faceBboxTransform(image.size.height))
                    continuation.resume(returning: normBbox)
                }catch{
                    continuation.resume(throwing: error)
                }
            }
        }
       
    }
    
    /// 피부 분할 후 픽셀들의 평균을 낸 RBG  값
    public func skinSegmentation(_ image: UIImage) -> (Int, Int, Int){
        let bgrNSArray = OpenCVWrapper.skinSegmentation(image)

        return (bgrNSArray[2] as! Int, bgrNSArray[1] as! Int, bgrNSArray[0] as! Int)
    }
    
    //MARK: private
    private init(){}
    private func track(buffer: CVPixelBuffer) throws -> CGRect{
        lock.lock()
        defer{lock.unlock()}
        guard let request = trackRequest else{
            return .zero
        }
        
        do{
            try self.sequenceHandler.perform([request], on: buffer)
        }catch{
            print(error)
            trackRequest = nil
            throw error
        }
        
        guard let results = request.results else {
            trackRequest = nil
            return .zero
        }
       
        guard let observation = results[0] as? VNDetectedObjectObservation else {
            trackRequest = nil
            return .zero
        }
        
        if !request.isLastFrame {
            if observation.confidence >= 0.5 {
                request.inputObservation = observation
            } else {
                request.isLastFrame = true
            }
            self.trackRequest = request
        }
        else{
            self.trackRequest = nil
            self.sequenceHandler = VNSequenceRequestHandler()
        }
        
        return observation.boundingBox
    }
    private func makeFaceDetectionRequset(continuation: CheckedContinuation<CGRect, Error>, size: CGSize) -> VNDetectFaceRectanglesRequest{
        return VNDetectFaceRectanglesRequest{[weak self] request, error in
            guard let results = request.results as? [VNFaceObservation] else{
                fatalError("VNFaceObservation으로 다운 캐스팅 실패")
            }
            guard let `self` = self else {
                return
            }
            guard error == nil else {
                continuation.resume(throwing: error!)
                return
            }
            
            if results.isEmpty{
                continuation.resume(returning: .zero)
            }
            else{
                let largestFace = results.reduce(VNFaceObservation(boundingBox: .zero)){
                    if $1.boundingBox.width * $1.boundingBox.height > $0.boundingBox.width * $0.boundingBox.height{
                        return $1
                    } else{
                        return $0
                    }
                }
                let normBbox = VNImageRectForNormalizedRect(largestFace.boundingBox, Int(size.width), Int(size.height))
                    .applying(self.faceBboxTransform(size.height))
                continuation.resume(returning: normBbox)
                
//                lock.lock()
//                self.trackRequest = VNTrackObjectRequest(detectedObjectObservation: largestFace)
//              
//                self.lock.unlock()
                
            }
        }
    }
    private let faceBboxTransform = {(height: CGFloat) -> CGAffineTransform in
        return CGAffineTransform.identity.scaledBy(x: 1, y: -1).translatedBy(x: 0, y: -height)
    }
    
    private var lock = NSLock()
    private var trackRequest: VNTrackObjectRequest? = nil
    private var sequenceHandler = VNSequenceRequestHandler()
}

extension FaceDetector: DependencyKey {
    public static let liveValue = FaceDetector()
    public static let testValue = FaceDetector()
}
