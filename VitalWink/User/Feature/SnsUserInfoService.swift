//
//  UserInfoService.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/16.
//

import Foundation
import KakaoSDKUser
import SwiftyJSON
import NaverThirdPartyLogin
import Alamofire
import GoogleSignIn
import AuthenticationServices

final class SnsUserInfoService{
    enum SnsUserInfoServiceError: LocalizedError{
        case notHaveToken
        
        var errorDescription: String?{
            switch self{
            case .notHaveToken:
                return "access token을 가져오는데 실패했습니다."
            }
        }
    }
    
    func getSnsUserInfo(_ type: UserModel.`Type`) async -> Result<UserModel, Error>{
        switch type{
        case .kakao:
            return await withCheckedContinuation{continuation in
                UserApi.shared.me{user, error in
                    guard error == nil else{
                        continuation.resume(returning: .failure(error!))
                        return
                    }
                    
                    let email = user?.kakaoAccount?.email ?? ""
                
                    continuation.resume(returning: .success(.init(id: "", password: "", email: email, gender: .man, birthday: .now, type: type)))
                }
            }
        case .naver:
            guard let tokenType = await NaverThirdPartyLoginConnection.getSharedInstance().tokenType else {
                return .failure(SnsUserInfoServiceError.notHaveToken)
            }
            guard let accessToken = await NaverThirdPartyLoginConnection.getSharedInstance().accessToken else {
                return .failure(SnsUserInfoServiceError.notHaveToken)
            }
            return await withCheckedContinuation{continuation in
                let url = "https://openapi.naver.com/v1/nid/me"
                
                AF.request(url,
                           method: .get,
                           encoding: JSONEncoding.default,
                           headers: ["Authorization": "\(tokenType) \(accessToken)"]
                ).responseDecodable(of: JSON.self) { [weak self] response in
                    guard let strongSelf = self else{
                        return
                    }
                    switch response.result{
                    case .success(let json):
                        let json = json["response"]
                        let email = json["email"].string ?? ""
                        let gender: UserModel.Gender = (json["gender"].string ?? "") == "M" ? .man : .woman
                        let birthdayString = json["birthday"].string ?? ""
                        let birthyearString = json["birthyear"].string ?? ""
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let birthday: Date = birthyearString.isEmpty || birthdayString.isEmpty ? Date.now : dateFormatter.date(from: "\(birthyearString)-\(birthdayString)")!
                    
                        continuation.resume(returning:.success(
                            .init(id: "", password: "", email: email, gender: gender, birthday: birthday, type: .naver)
                        ))
                    case .failure(let error):
                        continuation.resume(returning: .failure(error))
                    }
                }
            }
        case .google:
            return await withCheckedContinuation{continuation in
                GIDSignIn.sharedInstance.restorePreviousSignIn{
                    guard $1 == nil else{
                        continuation.resume(returning: .failure($1!))
                        return
                    }
                    guard let credential = $0 else{
                        continuation.resume(returning: .failure(SnsUserInfoServiceError.notHaveToken))
                        return
                    }
                    
                    let email = credential.profile?.email ?? ""
                    continuation.resume(returning: .success(.init(id: "", password: "", email: email, gender: .man, birthday: .now, type: .google)))
                }
            }
        case .apple:
            return .success(.init(id: "", password: "", email: "", gender: .man, birthday: Date(), type: .apple))
            
        default:
            return await withCheckedContinuation{continuation in
                UserApi.shared.me{user, error in
                    guard error == nil else{
                        continuation.resume(returning: .failure(error!))
                        return
                    }
                    
                    let email = user?.kakaoAccount?.email ?? ""
                    let gender: UserModel.Gender = user?.kakaoAccount?.gender == .Male ? .man : .woman
                    let birthdayString = user?.kakaoAccount?.birthday ?? ""
                    let birthYearString = user?.kakaoAccount?.birthyear ?? ""
                    let dateString = birthYearString + birthdayString
                    
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyyMMdd"
                    
                    let birthday = dateString.isEmpty ? .now : dateformatter.date(from: dateString)!
                    
                    continuation.resume(returning: .success(.init(id: "", password: "", email: email, gender: gender, birthday: birthday, type: type)))
                }
            }
        }
    }
    
}
