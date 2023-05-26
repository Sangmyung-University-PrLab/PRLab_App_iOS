//
//  Login.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/24.
//

import Foundation
import ComposableArchitecture
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

struct Login: ReducerProtocol{
    struct State: Equatable{
        
    }
    enum Action: Equatable{
        case kakao
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action{
        case .kakao:
            if UserApi.isKakaoTalkLoginAvailable(){
                UserApi.shared.loginWithKakaoTalk{_,_ in
                    
                }
            }else{
                UserApi.shared.loginWithKakaoAccount{_,_ in
                    
                }
            }
            return .none
        }
    }
}
