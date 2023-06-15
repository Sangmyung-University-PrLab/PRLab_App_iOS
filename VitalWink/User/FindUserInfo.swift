//
//  FindUserInfo.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/13.
//

import Foundation
import ComposableArchitecture
import OSLog

struct FindUserInfo: ReducerProtocol{
    struct State: Equatable{
        init(idRegex: String, passwordRegex: String,emailRegex: String){
            self.idRegex = idRegex
            self.emailRegex = emailRegex
            self.passwordRegex = passwordRegex
        }
        
        @BindingState var id = ""
        @BindingState var email = ""
        @BindingState var shouldShowChangePasswordView = false
        
        var isIdValid: Bool{
            id.range(of: idRegex, options:.regularExpression) != nil
        }
        var isEmailValid: Bool{
            email.range(of: emailRegex, options: .regularExpression) != nil
        }
        
        fileprivate(set) var isActivityIndicatorVisible = false
        fileprivate(set) var shouldViewDismiss = false
        fileprivate(set) var alertState: VitalWinkAlertState<Action>?
        fileprivate(set) var changePassword: ChangePassword.State? = nil
        
        fileprivate let idRegex: String
        fileprivate let emailRegex: String
        fileprivate let passwordRegex: String
        fileprivate var shouldReset = true
        enum FindPasswordStatus{
            case success(_ token: String), notFoundUser, inconsistentInformation
        }
        enum InfoType{
            case id, password
        }
    }
    
    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case findId
        case isIdAndEmailMatch
        case errorHandling(Error, State.InfoType)
        case successFindId(String?)
        case dismiss
        case alertDismiss
        case onDisappear
        case responseFindPasswordStatus(State.FindPasswordStatus)
        case changePassword(ChangePassword.Action)
        case changePasswordViewDismissed
    }
    
    var body: some ReducerProtocol<State, Action>{
        BindingReducer()
        Reduce{state, action in
            switch action{
            case .binding:
                return .none
            case .findId:
                state.isActivityIndicatorVisible = true
                return .run{[email = state.email] send in
                    switch await userAPI.findId(email: email){
                    case .success(let id):
                        await send(.successFindId(id))
                    case .failure(let error):
                        await send(.errorHandling(error, .id))
                    }
                }
            case .isIdAndEmailMatch:
                state.isActivityIndicatorVisible = true
                return .run{[email = state.email, id = state.id] send in
                    switch await userAPI.isIdAndEmailMatch(id: id, email: email){
                    case .success(let token):
                        await send(.responseFindPasswordStatus(.success(token)))
                    case .failure(let error):
                        guard let afError = error.asAFError else{
                            await send(.errorHandling(error,.password))
                            return
                        }
                        
                        guard afError.isResponseValidationError, let statusCode = afError.responseCode else{
                            await send(.errorHandling(afError, .password))
                            return
                        }
                    
                        if statusCode == 404{
                            await send(.responseFindPasswordStatus(.notFoundUser))
                        }
                        else if statusCode == 409{
                            await send(.responseFindPasswordStatus(.inconsistentInformation))
                        }
                        else{
                            await send(.errorHandling(afError, .password))
                        }
                    }
                }
                
            case .responseFindPasswordStatus(let status):
                state.isActivityIndicatorVisible = false
                switch status{
                case .success(let token):
                    state.shouldReset = false
                    state.changePassword = .init(token: token, passwordRegex: state.passwordRegex)
                    state.shouldShowChangePasswordView = true
                case .notFoundUser:
                    state.alertState = VitalWinkAlertState(title: "비밀번호 찾기", message: "가입되어 있지 않은 아이디입니다."){
                        VitalWinkAlertButtonState<Action>(title: "확인"){
                            return nil
                            
                        }
                    }
                case .inconsistentInformation:
                    state.alertState = VitalWinkAlertState(title: "비밀번호 찾기", message: "아이디와 비밀번호가 일치하지 않습니다."){
                        VitalWinkAlertButtonState<Action>(title: "확인"){
                            return nil
                        }
                    }
                default:
                    break
                }
                
                return .none
                
            case .errorHandling(let error, let infoType):
                state.isActivityIndicatorVisible = false
                let message = error.localizedDescription
                os_log(.error, log:.findUserInfo,"%@", message)
                let menu = infoType == .id ? "아이디 찾기" : "비밀번호 찾기"
                state.alertState = VitalWinkAlertState(title: menu, message: "\(menu) 중 오류가 발생하였습니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                return .none
            case .successFindId(let id):
                state.isActivityIndicatorVisible = false
                
                guard let id = id else{
                    state.alertState = VitalWinkAlertState(title: "아이디 찾기", message: "가입되어 있지 않은 아이디 입니다."){
                        VitalWinkAlertButtonState<Action>(title: "확인"){
                            return nil
                        }
                    }
                    return .none
                }
                
                state.alertState = VitalWinkAlertState(title: "아이디 찾기", message: "사용자님의 아이디는 **\(id)**입니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return .dismiss
                    }
                }
                return .none
            case .alertDismiss:
                state.alertState = nil
                return .none
            case .dismiss:
                state.shouldViewDismiss = true
                return .none
            case .onDisappear:
                if state.shouldReset{
                    state = State(idRegex: state.idRegex, passwordRegex: state.passwordRegex, emailRegex: state.emailRegex)
                }
                
                return .none
            case .changePassword:
                return .none
            case .changePasswordViewDismissed:
                state.shouldReset = true
                return .send(.dismiss)
            }
        }
        .ifLet(\.changePassword, action: /Action.changePassword){
            ChangePassword()
        }
    }
    
    
    @Dependency(\.keyChainManager) private var keyChainManager
    @Dependency(\.userAPI) private var userAPI
}
