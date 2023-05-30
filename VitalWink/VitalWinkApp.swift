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
import GoogleSignIn
import NaverThirdPartyLogin

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
        initNaverSDK()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView(store: Store(initialState: Root.State().login, reducer: Login()))
                .onOpenURL{
                    print($0)
                    if AuthApi.isKakaoTalkLoginUrl($0){
                        _ = AuthController.handleOpenUrl(url: $0)
                    }
                    else{
                        GIDSignIn.sharedInstance.handle($0)
                    }
                }
        }
    }
    
    
    func initNaverSDK(){
        guard let naverSDK = NaverThirdPartyLoginConnection.getSharedInstance() else{
            fatalError("네이버 로그인을 위한 인스턴스 가져오기에 실패하였습니다.")
        }
        naverSDK.resetToken()
        naverSDK.isNaverAppOauthEnable = true
        naverSDK.isInAppOauthEnable = true
        
        naverSDK.setOnlyPortraitSupportInIphone(true)
        naverSDK.serviceUrlScheme = kServiceAppUrlScheme
        naverSDK.consumerKey = kConsumerKey
        naverSDK.consumerSecret = kConsumerSecret
        naverSDK.appName = kServiceAppName
    }
}
