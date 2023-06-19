//
//  NaverLoginDelegate.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/26.
//
import Alamofire
import Foundation
import NaverThirdPartyLogin
import OSLog
import SwiftyJSON

final class NaverLoginDelegate: NSObject,NaverThirdPartyLoginConnectionDelegate{
    let loginStream: AsyncStream<Void>
    override init() {
        var continuation: AsyncStream<Void>.Continuation!
        loginStream = AsyncStream{
            continuation = $0
        }
        self.continuation = continuation
    }
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        continuation.yield()
//        guard let tokenType = NaverThirdPartyLoginConnection.getSharedInstance().tokenType else { return }
//        guard let accessToken = NaverThirdPartyLoginConnection.getSharedInstance().accessToken else { return }
//        let url = "https://openapi.naver.com/v1/nid/me"
//
//        AF.request(url,
//                   method: .get,
//                   encoding: JSONEncoding.default,
//                   headers: ["Authorization": "\(tokenType) \(accessToken)"]
//        ).responseDecodable(of: JSON.self) { [weak self] response in
//            guard let strongSelf = self else{
//                return
//            }
//            switch response.result{
//            case .success(let json):
//                let email = json["email"].string ?? ""
//                let gender: UserModel.Gender = (json["gender"].string ?? "") == "male" ? .man : .woman
//                let birthday = json["birthday"].string ?? ""
//                let birthyear = json["birthyear"].string ?? ""
//                
//                strongSelf.userModelStreamContinuation.yield(.success(
//                    .init(id: "", password: "", email: email, gender: gender, birthday: <#T##Date#>, type: .naver)
//                ))
//            case .failure(let error):
//                strongSelf.userModelStreamContinuation.yield(.failure(error))
//            }

   
//        }
        return
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        return
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        return
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        let message = error.localizedDescription
        os_log(.error, log: .login, "%@", message)
    }
    
    
    
    
    private let continuation: AsyncStream<Void>.Continuation
}
