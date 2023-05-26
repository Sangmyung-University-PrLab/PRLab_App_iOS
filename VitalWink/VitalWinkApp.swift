//
//  VitalWinkApp.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/08.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import ComposableArchitecture

@main
struct VitalWinkApp: App {
    
    init(){
        guard let info = Bundle.main.infoDictionary else{
            fatalError("Info.plist가 없습니다.")
        }
        guard let kakaoKey = info["KAKAO_KEY"] as? String else{
            fatalError("카카오 API를 위한 Key가 없습니다.")
        }
        KakaoSDK.initSDK(appKey: kakaoKey)
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView(store: Store(initialState: Root.State().login, reducer: Login()))
                .onOpenURL{
                    if AuthApi.isKakaoTalkLoginUrl($0){
                        _ = AuthController.handleOpenUrl(url: $0)
                    }
                    else{
                        GID
                    }
                }
        }
    }
}
