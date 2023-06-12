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
import OSLog

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
        @BindingState var id = ""
        @BindingState var password = ""
        var isLoginButtonDisabled: Bool{
            id.isEmpty || password.isEmpty
        }
        
        fileprivate(set) var isActivityIndicatorVisible = false
        fileprivate(set) var alertState:VitalWinkAlertState<Action>? = nil
        fileprivate(set) var status: Status = .notLogin
        
        enum Status: Equatable{
            case success(_ token: String)
            case notLogin
            case needSignUp
            case notFoundUser
            case inconsistenInformation
        }
    }
    enum Action: BindableAction{
        case login(_ type: LoginType)
        case binding(BindingAction<State>)
        case changeStatus(Login.State.Status)
        case errorHandling(Error) //예상치 못한 에러 발생 시
        case dismiss
    }
    
    var body: some ReducerProtocol<State, Action>{
        BindingReducer()
        
        Reduce{state, action in
            switch action{
            case .login(let type):
                state.isActivityIndicatorVisible = true
                switch type{
                case .kakao:
                    kakaoLogin()
                case .google:
                  googleLogin()
                case .naver:
                    naverLogin()
                case .apple:
                    break
                case .general:
                    return .run{[id = state.id, password = state.password] send in
                        let result = await generalLogin(id: id, password: password)
                        switch result {
                        case .success(let status):
                            await send(.changeStatus(status))
                        case .failure(let error):
                            await send(.errorHandling(error))
                        }
                    }
                }
                return .none
            case .binding:
                return .none
            case .changeStatus(let status):
                switch status{
                case .success(let token):
                    guard keyChainManager.saveTokenInKeyChain(token) else{
                        return .none
                    }
                case .notFoundUser:
                    state.alertState = VitalWinkAlertState(title: "VitalWink", message: "가입되어 있지 않은 아이디입니다."){
                        VitalWinkAlertButtonState<Action>(title: "확인"){
                            return nil
                            
                        }
                    }
                case .inconsistenInformation:
                    state.alertState = VitalWinkAlertState(title: "VitalWink", message: "아이디와 비밀번호가 일치하지 않습니다."){
                        VitalWinkAlertButtonState<Action>(title: "확인"){
                            return nil
                        }
                    }
                default:
                    break
                }
                state.isActivityIndicatorVisible = false
                return .none
            case .errorHandling(let error):
                state.isActivityIndicatorVisible = false
                
                let message = error.localizedDescription
                os_log(.error, log:.login,"%@", message)
                
                state.alertState = VitalWinkAlertState(title: "VitalWink", message: "로그인 중 오류가 발생하였습니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                
                return .none
            case .dismiss:
                state.alertState = nil
                return .none
            }
        }
    }
    
    enum LoginType{
        case kakao
        case google
        case naver
        case apple
        case general
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
    private func generalLogin(id: String, password: String) async -> Result<State.Status, Error>{
        switch await loginAPI.generalLogin(id: id, password: password){
        case .success(let token):
            return .success(.success(token))
        case .failure(let error):
            guard let afError = error.asAFError else{
                return .failure(error)
            }
            
            guard afError.isResponseValidationError, let statusCode = afError.responseCode else{
                return .failure(afError)
            }
        
            if statusCode == 404{
                return .success(.notFoundUser)
            }
            else if statusCode == 409{
                return .success(.inconsistenInformation)
            }
            else{
                return .failure(afError)
            }
        }
    }
    
    private let gidConfig: GIDConfiguration
    private let naverLoginDelgate = NaverLoginDelegate()
    @Dependency(\.loginAPI) private var loginAPI
    @Dependency(\.keyChainManager) private var keyChainManager
}


