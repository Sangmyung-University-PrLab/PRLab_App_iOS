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

public struct FaceDetector{
    public static let shared = Self()

    enum FaceDetectorError: LocalizedError{
        case getEmptyUIImage
        
        var errorDescription: String?{
            switch self{
            case .getEmptyUIImage:
                return "빈 UIImage를 받았습니다."
            }
        }
    }
    public func detect(in image: UIImage) -> Future<CGRect, Error>{
        guard let cgImage = image.cgImage else{
            return Future<CGRect, Error>{
                $0(.failure(FaceDetectorError.getEmptyUIImage))
            }
        }
        
        return Future<CGRect, Error>{promise in
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
                    let largestFace = getLargestFace(results.map{$0.boundingBox})
                    promise(.success(largestFace))
                }
            }
            
            do{
                try handler.perform([request])
            }catch{
                promise(.failure(error))
            }
        }
        
    }
    
    //MARK: private
    private init(){}
    private func getLargestFace(_ faces: [CGRect]) -> CGRect{
        return faces.reduce(CGRect.zero){
            if $1.width * $1.height > $0.width * $0.height{
                return $1
            } else{
                return $0
            }
        }
    }
}
