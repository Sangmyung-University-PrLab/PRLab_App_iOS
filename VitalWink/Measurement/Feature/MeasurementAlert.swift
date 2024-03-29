//
//  MeasurementAlert.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/25.
//

import Foundation
import ComposableArchitecture
import OSLog

struct MeasurementAlert: ReducerProtocol{
    struct State{
        fileprivate(set) var resultAlertState: VitalWinkContentAlertState<MeasurementResultView,Action>? = nil
        fileprivate(set) var alertState: VitalWinkAlertMessageState<Action>? = nil
        fileprivate(set) var menuAlertState: VitalWinkMenuAlertState<Action>? = nil
        fileprivate(set) var menu = Menu.State()
    }
    
    enum Action{
        case alertDismiss
        case resultAlertDismiss
        case shouldShowAlert(VitalWinkAlertMessageState<Action>)
        case showResult(_ result: MeasurementResult, _ measurementId : Int)
        case deleteResult(_ measurementId: Int)
        case errorHandling(Error)
        
        case menu(Menu.Action)
        case menuAlertAppear
        case menuAlertDismiss
        
        case shouldShowActivityIndicator
        case shouldDismissRootView
        case shouldShowReferenceView
    }
    
    
    var body: some ReducerProtocol<State, Action>{
        Reduce{state, action in
            switch action{
            case .deleteResult:
                return .none
            case .shouldShowAlert(let alert):
                state.alertState = alert
                return .none
            case .shouldShowReferenceView:
                return .none
            case .showResult(let result, let id):
                state.resultAlertState = VitalWinkContentAlertState{
                    VitalWinkAlertButtonState<Action>(title: "저장하기"){
                        return nil
                    }
                    VitalWinkAlertButtonState<Action>(title: "삭제하기", role: .distructive){
                        return .deleteResult(id)
                    }
                }content: {
                    MeasurementResultView(result)
                }
                return .none
            case .errorHandling(let error):
                state.alertState = .init(title: "측정", message: "측정 중 오류가 발생했습니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                let message = error.localizedDescription
                os_log(.error, log:.measurement,"%@", message)
                return .none
            case .shouldDismissRootView:
                return .none
            case .shouldShowActivityIndicator:
                return .none
            case .menu(let action):
                switch action{
                case .shouldShowReferenceView:
                    return .send(.shouldShowReferenceView)
                case .errorHandling(let error):
                    return .send(.errorHandling(error))
                case .confirmationWithdrawal:
                    return .send(.shouldShowActivityIndicator)
                case .shouldDismiss:
                    return .send(.shouldDismissRootView)
                case .failDeleteToken:
                    return .send(.menuAlertDismiss)
                default:
                    return .none
                }

            case .resultAlertDismiss:
                state.resultAlertState = nil
                return .none
            case .alertDismiss:
                state.alertState = nil
                return .none
            case .menuAlertDismiss:
                state.menuAlertState = nil
                return .none
            case .menuAlertAppear:
                state.menuAlertState = VitalWinkMenuAlertState{
                    VitalWinkAlertButtonState<Action>(title: "로그아웃", role: .distructive){
                        return .menu(.logout)
                    }
                    VitalWinkAlertButtonState<Action>(title: "기술출처", role: .distructive){
                        return .menu(.shouldShowReferenceView)
                    }
                    VitalWinkAlertButtonState<Action>(title: "회원탈퇴", role: .distructive){
                        return .menu(.withdrawal)
                    }
                    VitalWinkAlertButtonState<Action>(title: "닫기", role: .cancel){
                        return nil
                    }
                }
                return .none
            }
            
        }
        Scope(state: \.menu, action: /Action.menu){
            Menu()
        }
    }
}
