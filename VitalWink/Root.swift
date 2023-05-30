//
//  Root.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/24.
//

import Foundation
import ComposableArchitecture

struct Root: ReducerProtocol{
    struct State: Equatable{
        var login = Login.State()
    }
    
    enum Action{
        case login(Login.Action)
    }
    
    var body: some ReducerProtocol<State, Action>{
        Reduce{state, action in
            switch action{
            default:
                return .none
            }
        }
        
        Scope(state: \.login, action: /Action.login){
            Login()
        }
    }
}
