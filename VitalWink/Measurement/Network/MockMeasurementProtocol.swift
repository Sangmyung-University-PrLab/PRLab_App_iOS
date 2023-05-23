//
//  MockMeasurementProtocol.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/21.
//

import Foundation
import Alamofire
import SwiftyJSON

final class MockMeasurmentProtocol: URLProtocol{
    enum ResponseType{
        case error(Error)
        case success(HTTPURLResponse)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        //파라미터로 전달받은 요청을 처리할 수 있는지 여부
        guard let url = request.url, url.absoluteString.contains("measurement") else{
            return false
        }
        
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        //표준 버전의 request 반환
        return request
    }
    
    override func startLoading() {
        let data = setUpMockData()
        let response = setUpMockReseponse()
        
        client?.urlProtocol(self, didLoad: data!)
        client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .allowed)
        client?.urlProtocolDidFinishLoading(self)
    }
   
    override func stopLoading() {
     
    }
    
    //MARK: private
    private static var responseType: ResponseType!
    private static var dataType: MockDataType!
}

extension MockMeasurmentProtocol{
    enum MockError: Error{
        case none
    }
    enum MockDataType{
        case signalMeasurement
        case expressionAndBMI
        case fetchRecentData
        case fetchMetricDatas
    }
    static func responseWithFailure(){
        MockMeasurmentProtocol.responseType = MockMeasurmentProtocol.ResponseType.error(MockError.none)
    }
    
    static func responseWithStatusCode(code: Int){
        MockMeasurmentProtocol.responseType = MockMeasurmentProtocol.ResponseType.success(HTTPURLResponse(url: URL(string: "http://mock.com")!, statusCode: code, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!)
    }
    
    static func responseWithData(type: MockDataType){
        MockMeasurmentProtocol.dataType = type
    }
    
    private func setUpMockReseponse() -> HTTPURLResponse? {
        var response: HTTPURLResponse?
        switch MockMeasurmentProtocol.responseType{
        case .error(let error):
            client?.urlProtocol(self, didFailWithError: error)
        case .success(let newResponse):
            response = newResponse
        default:
            fatalError("테스트를 위한 반환을 찾을 수 없습니다.")
        }
        
        return response
    }
    
    private func setUpMockData() -> Data?{
        switch MockMeasurmentProtocol.dataType{
        case .signalMeasurement:
            guard let json = readRequestBodyStreamAsJSON() else{
                MockMeasurmentProtocol.responseWithStatusCode(code: 400)
                return Data()
            }
            
            let frames = json["frames"]
            guard frames.error == nil else{
                MockMeasurmentProtocol.responseWithStatusCode(code: 400)
                return Data()
            }
            
            return "{\"measurement_id\": \(frames.arrayValue[0].arrayValue[0].arrayValue[0])}"
                .data(using: .utf8)
        case .expressionAndBMI:
            return Data()
        case .fetchRecentData:
            return try! JSONEncoder().encode(RecentData.mock)
        case .fetchMetricDatas:
            let parameters = request.url!.absoluteString.split(separator: "/")
                .dropFirst()
            let metric = parameters[3]
    
            switch metric{
            case "bloodPressures":
                let response = MetricDataResponse(datas: [
                    .init(value: BloodPressureMetricValue.mock, basisDate: Date())
                ])
                return try! JSONEncoder().encode(response)
            case "expressionAnalyses":
                let response = MetricDataResponse(datas: [
                    .init(value: ExpressionAnalysisMetricValue.mock, basisDate: Date())
                ])
                return try! JSONEncoder().encode(response)
            default:
                let response = MetricDataResponse(datas: [
                    .init(value: MinMaxType(min: 1, max: 100), basisDate: Date())
                ])
                var encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                return try! encoder.encode(response)
            }
        default:
            return Data()
        }
    }
    
    
    private func readRequestBodyStreamAsJSON() -> JSON?{
        //프로토콜에서 바디를 받을 떄 bodyStream으로 받아와야 한다.
        guard let bodyStream = request.httpBodyStream else{
            return nil
        }
        bodyStream.open()

        let buffSize = 16
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: buffSize)
        var data = Data()

        while bodyStream.hasBytesAvailable{
            let readData = bodyStream.read(buffer, maxLength: buffSize)
            data.append(buffer, count: readData)
        }

        buffer.deallocate()
        bodyStream.close()
 
        return JSON(data)
    }
}
