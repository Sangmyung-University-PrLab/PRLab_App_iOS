//
//  AuthInterceptor.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/18.
//

import Foundation
import Alamofire
import Dependencies
final class AuthInterceptor: RequestInterceptor{
    @Dependency(\.keyChainManager) private var keyChainManager
    
    func adapt(_ urlRequest: URLRequest, using state: RequestAdapterState, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        if _XCTIsTesting{
            completion(.success(urlRequest))
            return
        }

        var urlRequest = urlRequest
       
        guard let token = keyChainManager.readTokenInKeyChain() else{
            completion(.failure(VitalWinkAPIError.notFoundToken))
            return
        }
        
        urlRequest.headers.add(name: "AUTH-TOKEN", value:token)
        completion(.success(urlRequest))
    }
}
