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


struct FaceDetector{
    static let shared = Self()

    func detect(in image: UIImage){
        let handler = VNImageRequestHandler(cgImage: image.cgImage!)
        let request = VNDetectFaceRectanglesRequest{request, error in
            
            guard let results = request.results as? [VNFaceObservation] else{
                fatalError("VNFaceObservation으로 다운 캐스팅 실패")
            }
            
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
            
            if results.isEmpty{
                self.faceObserver.send(CGRect.zero)
            }else{
                let largestFace = results.reduce(CGRect.zero){
                    if $1.boundingBox.width * $1.boundingBox.height > $0.width * $0.height{
                        return $1.boundingBox
                    } else{
                        return $0
                    }
                }
                self.faceObserver.send(largestFace)
            }
        }
    }
    
    //MARK: private
    private let faceObserver = PassthroughSubject<CGRect,Never>()
    private init(){}
}
