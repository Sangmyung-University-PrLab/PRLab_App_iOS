//
//  MockUserProtocol.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/18.
//

import Foundation
import Alamofire

final class MockUserProtocol: URLProtocol{
    enum ResponseType{
        case error(Error)
        case success(HTTPURLResponse)
    }
    
    static var responseType: ResponseType!
    static var dataType: MockDataType!
    override class func canInit(with request: URLRequest) -> Bool {
        //파라미터로 전달받은 요청을 처리할 수 있는지 여부
        guard let url = request.url, url.absoluteString.contains("users") else{
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
    
}

extension MockUserProtocol{
    enum MockError: Error{
        case none
    }
    enum MockDataType{
        case find
        case isIdNotExist
    }
    static func responseWithFailure(){
        MockUserProtocol.responseType = MockUserProtocol.ResponseType.error(MockError.none)
    }
    
    static func responseWithStatusCode(code: Int){
        MockUserProtocol.responseType = MockUserProtocol.ResponseType.success(HTTPURLResponse(url: URL(string: "http://mock.com")!, statusCode: code, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!)
    }
    
    static func responseWithData(type: MockDataType){
        MockUserProtocol.dataType = type
    }
    
    
    private func setUpMockReseponse() -> HTTPURLResponse? {
        var response: HTTPURLResponse?
        switch MockUserProtocol.responseType{
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
        switch MockUserProtocol.dataType{
        case .find:
            let url = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!
          
            guard let queryItem = url.queryItems,
                  let email = queryItem[0].value,
                  !email.isEmpty
            else {
                MockUserProtocol.responseWithStatusCode(code: 400)
                return Data()
            }
            return "{\"id\": \"\(email)\"}"
                .data(using: .utf8)
        default:
            return Data()
        }
    }
}

