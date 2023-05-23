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
    
    
    func test_expressionAndBMI(){
        MockMeasurmentProtocol.responseWithStatusCode(code: 201)
        MockMeasurmentProtocol.responseWithData(type: .expressionAndBMI)
        
        measurementAPI
            .expressionAndBMI(image: UIImage(systemName: "signature")!, id: 1)
            .sink(receiveCompletion: {
                switch $0{
                case .finished:
                    self.expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }).store(in: &subsriptions)
        wait(for: [expectation], timeout: 5)
    }
    
    
    func test_fetchRecentData(){
        MockMeasurmentProtocol.responseWithStatusCode(code: 200)
        MockMeasurmentProtocol.responseWithData(type: .fetchRecentData)
        
        measurementAPI.fetchRecentData()
            .sink(receiveCompletion: {
                switch $0{
                case .finished:
                    break
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                print($0)
                self.expectation.fulfill()
            }).store(in: &subsriptions)
        wait(for: [expectation], timeout: 5)
    }
    
    
    func test_fetchMetricDatas(){
        MockMeasurmentProtocol.responseWithStatusCode(code: 200)
        MockMeasurmentProtocol.responseWithData(type: .fetchMetricDatas)
        
        measurementAPI.fetchMetricDatas(.BMI, period: .day, basisDate: Date(), valueType: MinMaxType<Int>.self).sink(receiveCompletion: {
            switch $0{
            case .finished:
                self.expectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }, receiveValue: {
            print($0)
        }).store(in: &subsriptions)
        wait(for: [expectation], timeout: 5)
    }
    
    func test_fetchMeasurementResult(){
        MockMeasurmentProtocol.responseWithStatusCode(code: 200)
        MockMeasurmentProtocol.responseWithData(type: .fetchMeasurementResult)
        
        measurementAPI.fetchMeasurementResult(1)
            .sink(receiveCompletion: {
                switch $0{
                case .finished:
                    self.expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                print($0)
            }).store(in: &subsriptions)
        
        wait(for: [expectation], timeout: 5)
    }
}



