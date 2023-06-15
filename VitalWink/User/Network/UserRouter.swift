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
    case signUp(_ user: UserModel)
    case isIdAndEmailMatch(id: String, email: String)
    case changePassword(_ password: String, token: String)
    
    var endPoint: String{
        let baseEndPoint = "users"
        return "\(baseEndPoint)"
    }
    
    var parameters: Parameters{
        switch self{ 
        case .signUp(let user):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            return [
                "id": user.id,
                "password": user.password,
                "email": user.email,
                "gender": user.gender.rawValue,
                "birthday": dateFormatter.string(from: user.birthday),
                "type": user.type.rawValue
            ]
        case .changePassword(let password, _):
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
        case .signUp:
            return .post
        case .changePassword:
            return .patch
        }
    }
    
    var headers: HTTPHeaders{
        switch self {
        case .changePassword(_, let token):
            return [.init(name: "AUTH-TOKEN", value: token)]
        default:
            return []
        }
    }
}
