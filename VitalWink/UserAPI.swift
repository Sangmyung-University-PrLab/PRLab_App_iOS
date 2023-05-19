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
    func find(email: String) -> AnyPublisher<String, Error>{
        return vitalWinkAPI.request(UserRouter.find(email: email))
            .validate(statusCode: 200...200)
            .publishData()
            .value()
            .tryMap{
                let id = JSON($0)["id"]
                
                guard id.error == nil else{
                    throw id.error!
                }
                
                return id.stringValue
            }
            .eraseToAnyPublisher()
    }
    func isIdExist(id: String){
        
    }
    func regist(user: User){
        
    }
    func isIdAndEmailMatch(id: String, email: String){
        
    }
    func changePassword(password: String){
        
    }
    
    @Dependency(\.vitalWinkAPI) private var vitalWinkAPI
}

extension UserAPI: DependencyKey{
    static var liveValue: UserAPI = UserAPI()
    static var testValue: UserAPI = UserAPI()
}
