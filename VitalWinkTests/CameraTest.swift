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
    
    func test_camera_whenSetUp_notHaveCameraPermission() throws {
        // This is an example of a performance test case.
        let sut = Camera{
            guard $0 == nil else{
                print($0!.localizedDescription)
                XCTAssertNotNil($0 as? Camera.CameraError)
                return
            }
        }
    }

}
