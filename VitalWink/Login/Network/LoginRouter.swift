//
//  LoginRouter.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/08.
//

import Foundation
import Alamofire

enum LoginRouter: VitalWinkRouterType{
    case generalLogin(id: String, password: String)
    case snsLogin(_ type: UserModel.`Type`, token: String)
    var endPoint: String{
        let baseEndPoint = "login"
        let detailEndPoint: String
        switch self {
        case .generalLogin:
            detailEndPoint = ""
        case .snsLogin(let type, _):
            switch type {
            case .kakao:
                detailEndPoint = "/kakao"
            case .google:
                detailEndPoint = "/google"
            case .naver:
                detailEndPoint = "/naver"
            case .apple:
                detailEndPoint = "/apple"
            default:
                fatalError("지원하지 않는 SNS 타입입니다.")
            }
        }
        
        return "\(baseEndPoint)\(detailEndPoint)"
    }
    
    var method: Alamofire.HTTPMethod{
        switch self {
        default:
            return .post
        }
    }
    
    var parameters: Alamofire.Parameters{
        switch self {
        case .generalLogin(id: let id, password: let password):
            return [
                "id": id,
                "password": password
            ]
        case .snsLogin(_, token: let token):
            return [
                "token": token
            ]
        }
    }
    
    var queries: [URLQueryItem]{
        return []
    }
}
