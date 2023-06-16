//
//  UserInfoService.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/16.
//

import Foundation
import KakaoSDKUser

final class SnsUserInfoService{
    
    
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
           
        default:
            break
        }
    }
    
}
