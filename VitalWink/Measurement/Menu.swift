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
    }
    
    enum Action{
        case withdrawal
        case logout
        case shouldDismiss
        case errorHandling(Error)
        case failDeleteToken
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action{
        case .withdrawal:
            return .run{send in
                do{
                    try await userAPI.delete()
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
        }
    }
    @Dependency(\.userAPI) private var userAPI
    @Dependency(\.keyChainManager) private var keyChainManager
}
