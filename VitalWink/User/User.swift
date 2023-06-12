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
            || !isIdValid || !isPasswordValid || !isRepeatPasswordValid || !isEmailValid
        }
        
        var isIdValid: Bool{
            id.range(of: idRegex, options:.regularExpression) != nil
        }
        var isPasswordValid: Bool{
            password.range(of: passwordRegex, options: .regularExpression) != nil
        }
        var isRepeatPasswordValid: Bool{
            repeatPassword == password
        }
        var isEmailValid: Bool{
            email.range(of: emailRegex, options: .regularExpression) != nil
        }
        
        let idRegex = "^[A-Za-z0-9]{6,18}$"
        let passwordRegex = "^([!@#$%^&*()-=+A-Za-z0-9]){6,18}$"
        let emailRegex = "^([A-Za-z0-9._-])+@[A-Za-z0-9]+\\.[a-zA-Z]{2,}$"
    }
    
    enum Action: BindableAction{
        case signUp
        case binding(BindingAction<State>)
        case getError(Error)
        case duplicatedEmail
        case success
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
                            await send(.duplicatedEmail)
                        }else{
                            await send(.getError(afError))
                        }
                    }
                    else{
                        await send(.success)
                    }
                }
            case .binding:
                return .none
            case .getError(let error):
                print(error.localizedDescription)
                return .none
            case .duplicatedEmail:
                return .none
            case .success:
                return .none
            }
        }
    }
    
    @Dependency(\.userAPI) private var userAPI
}
