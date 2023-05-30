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
final class NaverLoginDelegate: NSObject,NaverThirdPartyLoginConnectionDelegate{
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        guard let tokenType = NaverThirdPartyLoginConnection.getSharedInstance().tokenType else { return }
        guard let accessToken = NaverThirdPartyLoginConnection.getSharedInstance().accessToken else { return }
        let url = "https://openapi.naver.com/v1/nid/me"
        
        AF.request(url,
                   method: .get,
                   encoding: JSONEncoding.default,
                   headers: ["Authorization": "\(tokenType) \(accessToken)"]
        ).responseJSON { [weak self] response in
            guard let result = response.value as? [String: Any] else { return }
            guard let object = result["response"] as? [String: Any] else { return }
            guard let email = object["email"] as? String else { return }
            guard let birthyear = object["birthyear"] as? String else { return }
            guard let birthday = object["birthday"] as? String else { return }
            guard let gender = object["gender"] as? String else { return }
            
            print(email)
            print(birthday)
            print(birthyear)
            print(gender)
        }
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
    
    
}
