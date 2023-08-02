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
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .leftMirrored)
        
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
                  
                    continuation.resume(returning: faceBboxTransform(rect: bbox, imageSize: image.size))
                }catch{
                    continuation.resume(throwing: error)
                }
            }
        }
       
    }
    
    /// 피부 분할 후 픽셀들의 평균을 낸 RBG  값
    public func skinSegmentation(_ image: UIImage) -> (Float, Float, Float){
        let rgbNSArray = OpenCVWrapper.skinSegmentation(image)

        return (rgbNSArray[2] as! Float, rgbNSArray[1] as! Float, rgbNSArray[0] as! Float)
    }
    
    //MARK: private
    private init(){}
    private func track(buffer: CVPixelBuffer) throws -> CGRect{
        guard let request = trackRequest else{
            return .zero
        }
        
        do{
            try self.sequenceHandler.perform([request], on: buffer, orientation: .leftMirrored)
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
                
                continuation.resume(returning: faceBboxTransform(rect:largestFace.boundingBox, imageSize: size))

                self.trackRequest = VNTrackObjectRequest(detectedObjectObservation: largestFace)
            }
        }
    }
    private func faceBboxTransform(rect: CGRect, imageSize: CGSize) -> CGRect{
        return VNImageRectForNormalizedRect(rect.applying(CGAffineTransform(rotationAngle: CGFloat(Double(90) * Double.pi / 180.0))), Int(imageSize.width), Int(imageSize.height))
            .applying(CGAffineTransform(translationX: imageSize.width, y: 0))
    }
    
    
    private var trackRequest: VNTrackObjectRequest? = nil
    private var sequenceHandler = VNSequenceRequestHandler()
}

extension FaceDetector: DependencyKey {
    public static let liveValue = FaceDetector()
    public static let testValue = FaceDetector()
}
