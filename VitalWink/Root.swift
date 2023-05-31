//
//  Root.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/24.
//

import Foundation
import ComposableArchitecture

struct Root: ReducerProtocol{
    struct State{
        var login = Login.State()
        var measurement = Measurement.State()
    }
    
    enum Action{
        case login(Login.Action)
        case measurement(Measurement.Action)
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
        
        Scope(state: \.measurement, action: /Action.measurement){
            Measurement()
        }
    }
}
