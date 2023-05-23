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
    case isIdExist(_ id: String)
    case regist(_ user: User)
    case isIdAndEmailMatch(id: String, email: String)
    case changePassword(_ password: String)
    
    var endPoint: String{
        let baseEndPoint = "users"
        return "\(baseEndPoint)"
    }
    
    var parameters: Parameters{
        switch self{
        case .regist(let user):
            return [
                "id": user.id,
                "password": user.password,
                "email": user.email,
                "gender": user.gender,
                "birthday": user.birthday
            ]
        case .changePassword(let password):
            return [
                "password": password
            ]
        default:
            return Parameters()
        }
    }
    var queries: [URLQueryItem]{
        switch self {
        case .find(let email):
            return [
                .init(name: "email", value: email)
            ]
        case .isIdExist(let id):
            return [
                .init(name: "id", value: id)
            ]
        case .isIdAndEmailMatch(let id, let email):
            return [
                .init(name: "id", value: id),
                .init(name: "email", value: email)
            ]
        default:
            return []
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