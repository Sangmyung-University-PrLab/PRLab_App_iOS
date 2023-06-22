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
        return try await withCheckedThrowingContinuation{continuation in
            let handler = VNImageRequestHandler(cgImage: cgImage)
            let request = VNDetectFaceRectanglesRequest{request, error in
                guard let results = request.results as? [VNFaceObservation] else{
                    fatalError("VNFaceObservation으로 다운 캐스팅 실패")
                }
                
                guard error == nil else {
                    continuation.resume(throwing: error!)
                    return
                }
                
                if results.isEmpty{
                    continuation.resume(returning: .zero)
                }else{
                    let largestBBox = self.getLargestBBox(results.map{$0.boundingBox})
                    let normBBox = VNImageRectForNormalizedRect(largestBBox, Int(image.size.width), Int(image.size.height))
                        .applying(self.faceBboxTransform(image.size.height))
                    continuation.resume(returning: normBBox)
                }
            }
            
            do{
                try handler.perform([request])
            }catch{
                continuation.resume(throwing: error)
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
    private func getLargestBBox(_ bboxes: [CGRect]) -> CGRect{
        return bboxes.reduce(CGRect.zero){
            if $1.width * $1.height > $0.width * $0.height{
                return $1
            } else{
                return $0
            }
        }
    }
    
    private let faceBboxTransform = {(height: CGFloat) -> CGAffineTransform in
        return CGAffineTransform.identity.scaledBy(x: 1, y: -1).translatedBy(x: 0, y: -height)
    }
}

extension FaceDetector: DependencyKey {
    public static let liveValue = FaceDetector()
    public static let testValue = FaceDetector()
}
