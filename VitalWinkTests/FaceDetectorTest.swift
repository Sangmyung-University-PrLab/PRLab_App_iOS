//
//  FaceDetectorTest.swift
//  VitalWinkTests
//
//  Created by 유호준 on 2023/05/10.
//

import XCTest
import Combine
import UIKit
//import Dependencies

@testable import VitalWink
final class FaceDetectorTest: XCTestCase {
//    let camera = try! Camera()
//    @Dependency(\.faceDetector) var sut
    var subscriptions = Set<AnyCancellable>()
    
//    func test_whenDetect_withNoFace(){
//        camera.start()
//        camera.sink(receiveValue: {[weak self] buffer in
//            guard let strongSelf = self else {
//                return
//            }
//            sut.detect(UIImage(sampleBuffer: buffer)).sink(receiveCompletion: {
//                switch $0{
//                case .finished:
//                    _ = 1
//                case .failure(let error):
//                    let detectorError = error as? FaceDetector.FaceDetectorError
//                    XCTAssertNotNil(detectorError)
//                    XCTAssertTrue(detectorError == FaceDetector.FaceDetectorError.getEmptyUIImage)
//                }
//            }, receiveValue: {
//                XCTAssertTrue($0 == CGRect.zero)
//            }).store(in: &strongSelf.subscriptions)
//        }).store(in: &subscriptions)
//    }
//                                  
//    func test_whenDetect_withEmptyUIImage(){
//        sut.detect(UIImage()).sink(receiveCompletion: {
//            switch $0{
//            case .finished:
//                _ = 1
//            case .failure(let error):
//                let detectorError = error as? FaceDetector.FaceDetectorError
//                XCTAssertNotNil(detectorError)
//                XCTAssertTrue(detectorError == FaceDetector.FaceDetectorError.getEmptyUIImage)
//            }
//        }, receiveValue: {
//            XCTAssertTrue($0 == CGRect.zero)
//        }).store(in: &subscriptions)
//         
//    }
}
