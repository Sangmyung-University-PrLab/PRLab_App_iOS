//
//  LoginAPI.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/08.
//

import Foundation
import Alamofire
import Dependencies
import SwiftyJSON
final class LoginAPI{
    func generalLogin(id: String, password: String) async -> Result<String, Error>{
        return await withCheckedContinuation{continuation in
            vitalWinkAPI.request(LoginRouter.generalLogin(id: id, password: password), requireToken: false)
                .validate(statusCode: 200...200)
                .responseDecodable(of:JSON.self){
                    switch $0.result{
                    case .success(let json):
                        let token = json["token"]
                        guard token.error == nil else{
                            continuation.resume(returning: .failure(token.error!))
                            return
                        }
                        continuation.resume(returning: .success(token.stringValue))
                    case .failure(let error):
                        continuation.resume(returning: .failure(error))
                    }
                }
        }
       
    }
    
    
    @Dependency(\.vitalWinkAPI) private var vitalWinkAPI
}

extension LoginAPI: DependencyKey{
    static var liveValue: LoginAPI = LoginAPI()
}
