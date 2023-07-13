//
//  Menu.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/12.
//

import Foundation
import ComposableArchitecture

struct Menu: ReducerProtocol{
    struct State{
        fileprivate(set) var error: Error?
        fileprivate(set) var dialog: ConfirmationDialogState<Action>? = nil
    }
    
    enum Action{
        case withdrawal
        case logout
        case shouldDismiss
        case errorHandling(Error)
        case failDeleteToken
        case confirmationWithdrawal
        case dialogDismiss
        case showDialog
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action{
        case .withdrawal:
            return .run{send in
                try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * 0.5))
                await send(.showDialog)
            }
        case .showDialog:
            state.dialog = ConfirmationDialogState{
                TextState("회원 탈퇴")
            }actions: {
                ButtonState(role: .cancel){
                    TextState("취소")
                }
                ButtonState(action:.confirmationWithdrawal){
                    TextState("확인")
                }
            }message: {
                TextState("정말 회원탈퇴 하시겠습니까?")
            }
            return .none
        case .confirmationWithdrawal:
            return .run{send in
                do{
                    try await userAPI.delete()
                    _ = keyChainManager.deleteTokenInKeyChain()
                    await send(.shouldDismiss)
                }catch{
                    await send(.errorHandling(error))
                }
            }
        case .logout:
            return .send( keyChainManager.deleteTokenInKeyChain() ? .shouldDismiss : .failDeleteToken)
        case .errorHandling:
            return .none
        case .failDeleteToken:
            return .none
        case .shouldDismiss:
            return .none
        case .dialogDismiss:
            state.dialog = nil
            return .none
        }
    }
    @Dependency(\.userAPI) private var userAPI
    @Dependency(\.keyChainManager) private var keyChainManager
}
