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
    
    func test_camera_whenInit_notHaveCameraPermission() async{
        // This is an example of a performance test case.
        do{
            let _ = try await Camera()
        }catch{
            let cameraError = error as? Camera.CameraError
            XCTAssertNotNil(cameraError)
            XCTAssertTrue(cameraError == .notHavePermission)
        }
    }
    
    func test_camera_whenInit_noHaveCamera() async{
        do{
            let _ = try await Camera()
        }catch{
            let cameraError = error as? Camera.CameraError
            XCTAssertNotNil(cameraError)
            XCTAssertTrue(cameraError == .notFoundCamera)
        }
    }
}
