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
import GoogleSignIn
import NaverThirdPartyLogin

struct Login: ReducerProtocol{
    init(){
        guard let info = Bundle.main.infoDictionary else{
            fatalError("Info.plist가 없습니다.")
        }
        
        guard let clientId = info["GOOGLE_CLIENT_ID"] as? String else{
            fatalError("구글 로그인을 위한 클라이언트 아이디가 존재하지 않습니다.")
        }
        
        gidConfig = GIDConfiguration(clientID: clientId)
        NaverThirdPartyLoginConnection.getSharedInstance().delegate = naverLoginDelgate
    }
    
    struct State: Equatable{
        
    }
    enum Action: Equatable{
        case login(_ type: LoginType)
    }
    
    
    enum LoginType{
        case kakao
        case google
        case naver
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action{
        case .login(let type):
            switch type{
            case .kakao:
                kakaoLogin()
            case .google:
              googleLogin()
            case .naver:
                naverLogin()
            }
           
            return .none
        }
    }
    
    //MARK: private
    private func googleLogin(){
        guard let windowScenes = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootContoller = windowScenes.windows.first?.rootViewController else{
            return
        }
        
        GIDSignIn.sharedInstance.signIn(with: gidConfig, presenting: rootContoller){
            guard $1 == nil else{
                print($1!.localizedDescription)
                return
            }
            
            guard let credential = $0 else{
                print("credential이 nil입니다.")
                return
            }
            print(credential.profile?.email)
        }
    }
    
    private func kakaoLogin(){
        if UserApi.isKakaoTalkLoginAvailable(){
            UserApi.shared.loginWithKakaoTalk{_,_ in
                
            }
        }else{
            UserApi.shared.loginWithKakaoAccount{_,_ in
                
            }
        }
    }
    
    private func naverLogin(){
        NaverThirdPartyLoginConnection.getSharedInstance().requestThirdPartyLogin()
    }
    
    private let gidConfig: GIDConfiguration
    private let naverLoginDelgate = NaverLoginDelegate()
}


