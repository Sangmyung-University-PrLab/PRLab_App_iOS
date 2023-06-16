//
//  UserAPI.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/18.
//

import Foundation
import Dependencies
import SwiftyJSON
import Combine
import Alamofire

final class UserAPI{
    func findId(email: String) async -> Result<String?, Error>{
        return await withCheckedContinuation{continuation in
            vitalWinkAPI.request(UserRouter.find(email: email), requireToken: false)
                .validate(statusCode: 200 ..< 300)
                .responseDecodable(of: JSON.self){
                    switch $0.result{
                    case .success(let json):
                        let id = json["id"]
                        
                        if id.error != nil{
                            continuation.resume(returning: .failure(id.error!))
                            return
                        }
                        
                        continuation.resume(returning: .success(id.stringValue))
                    case .failure(let error):
                        guard error.isResponseValidationError, let statusCode = error.responseCode else{
                            continuation.resume(returning: .failure(error))
                            return
                        }
                        
                        if statusCode == 404{
                            continuation.resume(returning: .success(nil))
                        }else{
                            continuation.resume(returning: .failure(error))
                        }
                    }
                }
        }
    }
    func isIdDuplicated(_ id: String) async -> Result<Bool, Error>{
        return await withCheckedContinuation{continuation in
            vitalWinkAPI.request(UserRouter.isIdExist(id), requireToken: false)
                .validate(statusCode: 200 ..< 300)
                .response{
                    switch $0.result{
                    case .success:
                        continuation.resume(returning: .success(true))
                    case .failure(let error):
                        guard error.isResponseValidationError, let statusCode = error.responseCode else{
                            continuation.resume(returning: .failure(error))
                            return
                        }
                        
                        if statusCode == 404{
                            continuation.resume(returning: .success(false))
                        }
                        else{
                            continuation.resume(returning: .failure(error))
                        }
                    }
                }
        }
    }
    func signUp(_ user: UserModel) async throws{
        return try await withCheckedThrowingContinuation{continuation in
            vitalWinkAPI.request(UserRouter.signUp(user), requireToken: false)
                .validate(statusCode: 200 ..< 300)
                .response{
                    switch $0.result{
                    case .success(_):
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    func isIdAndEmailMatch(id: String, email: String) async -> Result<String, Error>{
        return await withCheckedContinuation{continuation in
            vitalWinkAPI.request(UserRouter.isIdAndEmailMatch(id: id, email: email), requireToken: false)
            .validate(statusCode: 200 ..< 300)
            .responseDecodable(of: JSON.self){
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
    func changePassword(_ password: String, token: String) async throws{
        return try await withCheckedThrowingContinuation{continuation in
            vitalWinkAPI.request(UserRouter.changePassword(password, token: token),requireToken: false)
                .validate(statusCode: 200 ..< 300)
                .response{
                    switch $0.result{
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    @Dependency(\.vitalWinkAPI) private var vitalWinkAPI
}

extension UserAPI: DependencyKey{
    static var liveValue: UserAPI = UserAPI()
    static var testValue: UserAPI = UserAPI()
}
