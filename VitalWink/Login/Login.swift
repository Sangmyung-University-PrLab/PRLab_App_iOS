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

    struct State: Equatable{
        @BindingState var id = ""
        @BindingState var password = ""
        @BindingState var shouldShowSignUpView = false
        @BindingState var shouldShowMeasurementView = false
        var isLoginButtonDisabled: Bool{
            id.isEmpty || password.isEmpty
        }
    
        fileprivate(set) var isActivityIndicatorVisible = false
        fileprivate(set) var alertState:VitalWinkAlertMessageState<Action>? = nil
        
        fileprivate(set) var user =  User.State()
        fileprivate(set) var measurement =  Measurement.State()
    }
    enum Action: BindableAction{
        case user(User.Action)
        case measurement(Measurement.Action)
        case login(_ type: UserModel.`Type`)
        case binding(BindingAction<State>)
        case responseStatus(LoginService.Status)
        case errorHandling(Error) //예상치 못한 에러 발생 시
        case dismiss
        case shouldSignUp(_ type: UserModel.`Type`)
        case restoreLogin
        case onAppear
        case onDisappear
    }
    
    var body: some ReducerProtocol<State, Action>{
        BindingReducer()
        
        Reduce{state, action in
            switch action{
            case .onDisappear:
                state.id = ""
                state.password = ""
                state.isActivityIndicatorVisible = false
                return .none
            case .onAppear:
                state.isActivityIndicatorVisible = true
                
                return .run{send in
                    try! await Task.sleep(nanoseconds: UInt64(1_000_000_000 * 0.5))
                    await send(.restoreLogin)
                }
            case .restoreLogin:
                state.shouldShowMeasurementView = keyChainManager.readTokenInKeyChain() != nil
                state.isActivityIndicatorVisible = false
                
                return .none
            case .measurement:
                return .none
            case .user:
                return .none
            case .login(let type):
                state.isActivityIndicatorVisible = true
                switch type{
                case .general:
                    return .run{[id = state.id, password = state.password] send in
                        switch await loginService.generalLogin(id: id, password: password) {
                        case .success(let status):
                            await send(.responseStatus(status))
                        case .failure(let error):
                            await send(.errorHandling(error))
                        }
                    }
                default:
                    return .run{send in
                        switch await loginService.snsLogin(type){
                        case .success(let status):
                            switch status{
                            case .success:
                                await send(.responseStatus(status))
                            case .shouldSignUp:
                                await send(.shouldSignUp(type))
                            default:
                                fatalError("지원하지 않는 상태입니다.")
                            }
                        case .failure(let error):
                            await send(.errorHandling(error))
                        }

                    }
                }
            case .binding:
                return .none
            case .responseStatus(let status):
                state.isActivityIndicatorVisible = false
                switch status{
                case .success(let token):
                    guard keyChainManager.saveTokenInKeyChain(token) else{
                        return .none
                    }
                    state.shouldShowMeasurementView = true
                    
                case .notFoundUser:
                    state.alertState = VitalWinkAlertMessageState(title: "VitalWink", message: "가입되어 있지 않은 아이디입니다."){
                        VitalWinkAlertButtonState<Action>(title: "확인"){
                            return nil
                            
                        }
                    }
                case .inconsistentInformation:
                    state.alertState = VitalWinkAlertMessageState(title: "VitalWink", message: "아이디와 비밀번호가 일치하지 않습니다."){
                        VitalWinkAlertButtonState<Action>(title: "확인"){
                            return nil
                        }
                    }
                default:
                    break
                }
                
                return .none
            case .errorHandling(let error):
                state.isActivityIndicatorVisible = false
                
                let message = error.localizedDescription
                os_log(.error, log:.login,"%@", message)
                
                state.alertState = VitalWinkAlertMessageState(title: "VitalWink", message: "로그인 중 오류가 발생하였습니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                
                return .none
            case .dismiss:
                state.alertState = nil
                return .none
            case .shouldSignUp(let type):
                state.user = User.State(type)
                state.isActivityIndicatorVisible = false
                state.shouldShowSignUpView = true
                return .none
            }
        }
        Scope(state: \.user, action: /Action.user){
            User()
        }
        Scope(state: \.measurement, action: /Action.measurement){
            Measurement()
        }

    }
    
    private let loginService = LoginService()
    @Dependency(\.keyChainManager) private var keyChainManager
}


