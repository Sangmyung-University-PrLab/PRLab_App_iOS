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
    func find(email: String) -> AnyPublisher<String?, Error>{
        return Future<String?, Error>{[weak self] promise in
            guard let strongSelf = self else{
                return
            }
            
            strongSelf.vitalWinkAPI
                .request(UserRouter.find(email: email), requireToken: false)
                .validate(statusCode: 200...200)
                
                .responseDecodable(of: JSON.self){
                    switch $0.result{
                    case .success(let json):
                        let id = json["id"]
                        
                        if id.error != nil{
                            promise(.failure(id.error!))
                            return
                        }
                        
                        promise(.success(id.stringValue))
                    case .failure(let error):
                        if let statusCode = error.responseCode{
                            if statusCode == 404{
                                promise(.success(nil))
                            }
                            else{
                                promise(.failure(error))
                            }
                        }
                        else{
                            promise(.failure(error))
                        }
                    }
                }
        }.eraseToAnyPublisher()
    }
    func isIdNotExist(_ id: String) -> AnyPublisher<Bool, Error>{
        return Future<Bool, Error>{[weak self] promise in
            guard let strongSelf = self else{
                return
            }
            
            strongSelf.vitalWinkAPI
                .request(UserRouter.isIdExist(id), requireToken: false)
                .validate(statusCode: 204...204)
                .response{
                    switch $0.result{
                    case .success:
                        promise(.success(false))
                    case .failure(let error):
                        if error.responseCode! == 404{
                            promise(.success(true))
                        }
                        else{
                            promise(.failure(error))
                        }
                    }
                }
        }.eraseToAnyPublisher()
        
    }
    func regist(_ user: User) ->  AnyPublisher<Never, AFError>{
        return vitalWinkAPI.request(UserRouter.regist(user), requireToken: false)
            .validate(statusCode: 204...204)
            .publishUnserialized()
            .value()
            .ignoreOutput()
            .eraseToAnyPublisher()
     
    }
    func isIdAndEmailMatch(id: String, email: String) -> AnyPublisher<String, Error>{
        return vitalWinkAPI.request(UserRouter.isIdAndEmailMatch(id: id, email: email), requireToken: false)
            .validate(statusCode: 200...200)
            .publishDecodable(type:JSON.self)
            .value()
            .tryMap{
                let token = $0["token"]
                guard token.error == nil else{
                    throw token.error!
                }
                
                return token.stringValue
            }
            .eraseToAnyPublisher()
    }
    func changePassword(_ password: String) -> AnyPublisher<Never, AFError>{
        return vitalWinkAPI.request(UserRouter.changePassword(password))
            .validate(statusCode: 204...204)
            .publishUnserialized()
            .value()
            .ignoreOutput()
            .eraseToAnyPublisher()
    }
    
    @Dependency(\.vitalWinkAPI) private var vitalWinkAPI
}

extension UserAPI: DependencyKey{
    static var liveValue: UserAPI = UserAPI()
    static var testValue: UserAPI = UserAPI()
}
