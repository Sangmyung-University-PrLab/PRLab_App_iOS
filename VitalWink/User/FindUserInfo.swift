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
        init(idRegex: String, emailRegex: String){
            self.idRegex = idRegex
            self.emailRegex = emailRegex
        }
        
        @BindingState var id = ""
        @BindingState var email = ""
        
        
        var isIdValid: Bool{
            id.range(of: idRegex, options:.regularExpression) != nil
        }
        var isEmailValid: Bool{
            email.range(of: emailRegex, options: .regularExpression) != nil
        }
        
        fileprivate(set) var isActivityIndicatorVisible = false
        fileprivate(set) var shouldViewDismiss = false
        fileprivate(set) var alertState: VitalWinkAlertState<Action>?
        fileprivate let idRegex: String
        fileprivate let emailRegex: String
        
    }
    
    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case findId
        case errorHandling(Error)
        case successFindId(String?)
        case dismiss
        case alertDismiss
        case onDisappear

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
                        await send(.errorHandling(error))
                    }
                }
            case .errorHandling(let error):
                state.isActivityIndicatorVisible = false
                let message = error.localizedDescription
                os_log(.error, log:.findId,"%@", message)
                
                state.alertState = VitalWinkAlertState(title: "아이디 찾기", message: "아이디 찾기 중 오류가 발생하였습니다."){
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
                state = State(idRegex: state.idRegex, emailRegex: state.emailRegex)
                return .none
            }
        }
    }
    
    @Dependency(\.userAPI) private var userAPI
}
