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
import Combine
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
    
    public func detect(_ image: UIImage) -> Future<CGRect, Error>{
        guard let cgImage = image.cgImage else{
            return Future<CGRect, Error>{
                $0(.failure(FaceDetectorError.getEmptyUIImage))
            }
        }
        
        return Future<CGRect, Error>{[weak self] promise in
            guard let strongSelf = self else{
                return
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage)
            
            let request = VNDetectFaceRectanglesRequest{request, error in
                guard let results = request.results as? [VNFaceObservation] else{
                    fatalError("VNFaceObservation으로 다운 캐스팅 실패")
                }
                guard error == nil else {
                    promise(.failure(error!))
                    return
                }
                
                if results.isEmpty{
                    promise(.success(CGRect.zero))
                }else{
                    let largestBBox = strongSelf.getLargestBBox(results.map{$0.boundingBox})
                    let normBBox = VNImageRectForNormalizedRect(largestBBox, Int(image.size.width), Int(image.size.height))
                        .applying(strongSelf.faceBboxTransform(image.size.height))
                    
                    promise(.success(normBBox))
                }
            }
            
            do{
                try handler.perform([request])
            }catch{
                promise(.failure(error))
            }
        }
        
    }
    
    public func skinSegmentation(_ image: UIImage){
        OpenCVWrapper.skinSegmentation(image)
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
