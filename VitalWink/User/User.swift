//
//  User.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/11.
//

import Foundation
import ComposableArchitecture

struct User: ReducerProtocol{
    struct State{
        init(){
            let idRegex = "^[A-Za-z0-9]{6,18}$"
            let passwordRegex = "^([!@#$%^&*()-=+A-Za-z0-9]){6,18}$"
            let emailRegex = "^([A-Za-z0-9._-])+@[A-Za-z0-9]+\\.[a-zA-Z]{2,}$"
            
            
            signUp = .init(idRegex: idRegex, passwordRegex: passwordRegex, emailRegex: emailRegex)
            findUserInfo = .init(idRegex: idRegex, emailRegex: emailRegex)
        }
        
        var signUp: SignUp.State
        var findUserInfo: FindUserInfo.State
    }
    
    enum Action{
        case signUp(SignUp.Action)
        case findUserInfo(FindUserInfo.Action)
        
    }
    
    var body: some ReducerProtocol<State, Action>{
        Reduce{state, action in
            switch action{
            default:
                return .none
            }
        }
        
        Scope(state: \.signUp, action: /Action.signUp){
            SignUp()
        }
        Scope(state: \.findUserInfo, action: /Action.findUserInfo){
            FindUserInfo()
        }
    }
}
