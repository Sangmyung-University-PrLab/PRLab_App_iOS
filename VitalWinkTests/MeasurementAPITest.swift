//
//  MeasurementAPITest.swift
//  VitalWinkTests
//
//  Created by 유호준 on 2023/05/21.
//

import XCTest
import Dependencies
import Combine

@testable import VitalWink

final class MeasurementAPITest: XCTestCase {
    @Dependency(\.measurementAPI) private var measurementAPI
    private var subsriptions = Set<AnyCancellable>()
    private let expectation = XCTestExpectation(description: "성능")
    
    func test_signalMeasurment(){
        MockMeasurmentProtocol.responseWithStatusCode(code: 201)
        MockMeasurmentProtocol.responseWithData(type: .signalMeasurement)
        
        measurementAPI
            .signalMeasurment(frames: [[[1,1,1]]], type: .face)
            .sink(receiveCompletion: {
                switch $0{
                case .finished:
                    break
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssert($0 == 1)
                self.expectation.fulfill()
            }).store(in: &subsriptions)
        wait(for: [expectation], timeout: 5)
    }

}



