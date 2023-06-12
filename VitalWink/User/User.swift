//
//  User.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/11.
//

import Foundation
import ComposableArchitecture
struct User: ReducerProtocol{
    struct State: Equatable{
        @BindingState var id = ""
        @BindingState var password = ""
        @BindingState var repeatPassword = ""
        @BindingState var email = ""
        @BindingState var gender: UserModel.Gender = .man
        @BindingState var birthday = Date.now
        
        var isSignUpButtonDisabled: Bool{
            id.isEmpty || password.isEmpty || repeatPassword.isEmpty || email.isEmpty
        }
        fileprivate(set) var status: Status = .notSignUp
        
        enum Status{
            case notSignUp
            case duplicatedEmail
            case success
        }
    }
    
    enum Action: BindableAction{
        case signUp
        case binding(BindingAction<State>)
        case getError(Error)
        case changeStatus(State.Status)
    }
    
    var body: some ReducerProtocol<State, Action>{
        BindingReducer()
        Reduce{state, action in
            switch action{
            case .signUp:
                let user = UserModel(id: state.id, password: state.password, email: state.email, gender: state.gender, birthday: state.birthday)
                
                return .run{ send in
                    if let afError = await userAPI.signUp(user){
                        guard afError.isResponseValidationError, let statusCode = afError.responseCode else{
                            await send(.getError(afError))
                            return
                        }
                        
                        if statusCode == 409{
                            await send(.changeStatus(.duplicatedEmail))
                        }else{
                            await send(.getError(afError))
                        }
                    }
                    else{
                        await send(.changeStatus(.success))
                    }
                }
            case .binding:
                return .none
            case .getError(let error):
                print(error.localizedDescription)
                return .none
            case .changeStatus(let status):
                state.status = status
                return .none
            }
        }
    }
    
    @Dependency(\.userAPI) private var userAPI
}
