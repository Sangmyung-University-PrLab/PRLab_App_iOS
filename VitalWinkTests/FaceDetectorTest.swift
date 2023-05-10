//
//  FaceDetectorTest.swift
//  VitalWinkTests
//
//  Created by 유호준 on 2023/05/10.
//

import XCTest
import Combine
import UIKit
@testable import VitalWink
final class FaceDetectorTest: XCTestCase {
    let camera = Camera{
        guard $0 == nil else{
            print($0!.localizedDescription)
            return
        }
    }
    var subscriptions = Set<AnyCancellable>()
    
    func test_whenDetect_withNoFace(){
        let sut = FaceDetector.shared
        camera.start()
        camera.frameObserver.sink(receiveValue: {[weak self] buffer in
            guard let strongSelf = self else {
                return
            }
            sut.detect(in: UIImage(sampleBuffer: buffer)).sink(receiveCompletion: {
                switch $0{
                case .finished:
                    _ = 1
                case .failure(let error):
                    let detectorError = error as? FaceDetector.FaceDetectorError
                    XCTAssertNotNil(detectorError)
                    XCTAssertTrue(detectorError == FaceDetector.FaceDetectorError.getEmptyUIImage)
                }
            }, receiveValue: {
                XCTAssertTrue($0 == CGRect.zero)
            }).store(in: &strongSelf.subscriptions)
        }).store(in: &subscriptions)
    }
                                  
    func test_whenDetect_withEmptyUIImage(){
        let sut = FaceDetector.shared
        sut.detect(in: UIImage()).sink(receiveCompletion: {
            switch $0{
            case .finished:
                _ = 1
            case .failure(let error):
                let detectorError = error as? FaceDetector.FaceDetectorError
                XCTAssertNotNil(detectorError)
                XCTAssertTrue(detectorError == FaceDetector.FaceDetectorError.getEmptyUIImage)
            }
        }, receiveValue: {
            XCTAssertTrue($0 == CGRect.zero)
        }).store(in: &subscriptions)
         
    }
}
