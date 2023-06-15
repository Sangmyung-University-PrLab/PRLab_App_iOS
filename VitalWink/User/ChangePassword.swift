//
//  ChangePassword.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/15.
//

import Foundation
import ComposableArchitecture
import OSLog

struct ChangePassword: ReducerProtocol{
    struct State: Equatable{
        init(token: String, passwordRegex: String){
            self.token = token
            self.passwordRegex = passwordRegex
        }
        
        @BindingState var password = ""
        @BindingState var repeatPassword = ""
        
        var isPasswordValid: Bool{
            password.range(of: passwordRegex, options: .regularExpression) != nil
        }
        
        var isRepeatPasswordValid: Bool{
            repeatPassword == password
        }
        
        fileprivate(set) var alertState: VitalWinkAlertState<Action>? = nil
        fileprivate(set) var isActivityIndicatorVisible = false
        fileprivate(set) var shouldViewDismiss = false
        fileprivate let token: String
        private let passwordRegex: String
    }
    
    enum Action: BindableAction{
        case changePassword
        case errorHandling(Error)
        case success
        case alertDismiss
        case dismiss
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce{state, action in
            switch action{
            case .binding:
                return .none
            case .changePassword:
                state.isActivityIndicatorVisible = true
                return .run{[token = state.token, password = state.password] send in
                    do{
                        try await userAPI.changePassword(password, token: token)
                        await send(.success)
                    }catch{
                        await send(.errorHandling(error))
                    }
                }
            case .errorHandling(let error):
                state.isActivityIndicatorVisible = false
                let message = error.localizedDescription
                os_log(.error, log:.findUserInfo,"%@", message)
                
                state.alertState = VitalWinkAlertState(title: "비밀번호 변경", message: "비밀번호 변경 중 오류가 발생하였습니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                
                return .none
            case .success:
                state.isActivityIndicatorVisible = false
                state.alertState = VitalWinkAlertState(title: "비밀번호 변경", message: "비밀번호가 성공적으로 변경되었습니다."){
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
            }
        }
    }
    
    @Dependency(\.userAPI) private var userAPI
}
