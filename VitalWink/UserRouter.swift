//
//  UserRouter.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/17.
//

import Foundation
import Alamofire

enum UserRouter: VitalWinkRouterType{
    case find(email: String)
    case isIdExist(id: String)
    case regist(user: User)
    case isIdAndEmailMatch(id: String, email: String)
    case changePassword(password: String)
    
    var endPoint: String{
        let baseEndPoint = "users"
        switch self{
        case .find(email: let email):
            return "\(baseEndPoint)?email=\(email)"
        case .isIdExist(id: let id):
            return "\(baseEndPoint)?id=\(id)"
        case .isIdAndEmailMatch(id: let id, email: let email):
            return "\(baseEndPoint)?id=\(id)&email=\(email)"
        default:
            return baseEndPoint
        }
    }
    
    var parameters: Parameters{
        switch self{
        case .regist(user: let user):
            return [
                "id": user.id,
                "password": user.password,
                "email": user.email,
                "gender": user.gender,
                "birthday": user.birthday
            ]
        default:
            return Parameters()
        }
    }
    
    var method: HTTPMethod{
        switch self {
        case .find, .isIdExist, .isIdAndEmailMatch:
            return .get
        case .regist:
            return .post
        case .changePassword:
            return .patch
        }
    }
}
