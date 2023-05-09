//
//  VitalWinkTests.swift
//  VitalWinkTests
//
//  Created by 유호준 on 2023/05/08.
//

import XCTest
import Combine

@testable import VitalWink

final class CameraTest: XCTestCase {
    
    func test_camera_whenInit_notHaveCameraPermission() throws {
        // This is an example of a performance test case.
        _ = Camera{
            guard $0 == nil else{
                print($0!.localizedDescription)
                XCTAssertNotNil($0 as? Camera.CameraError)
                return
            }
        }
    }
    
    func test_camera_whenInit_noHaveCamera(){
        _ = Camera{
            guard $0 == nil else{
                print($0!.localizedDescription)
                let cameraError = $0 as? Camera.CameraError
                XCTAssertNotNil(cameraError)
                XCTAssertTrue(cameraError == .notFoundCamera)
                return
            }
        }
    }
}
