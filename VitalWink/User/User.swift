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
            !fieldsAreNotEmpty || !fieldsAreValid || isIdDuplicated == nil || (isIdDuplicated != nil && isIdDuplicated!)
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
        
        fileprivate(set) var isIdDuplicated: Bool? = nil
        fileprivate(set) var alert: VitalWinkAlertState<Action>? = nil
        fileprivate(set) var isActivityIndicatorVisible = false
        
        //MARK: private
        private var fieldsAreNotEmpty: Bool{
            !(id.isEmpty || password.isEmpty || repeatPassword.isEmpty || email.isEmpty)
        }
        private var fieldsAreValid: Bool{
            isIdValid && isPasswordValid && isRepeatPasswordValid && isEmailValid
        }
        private let idRegex = "^[A-Za-z0-9]{6,18}$"
        private let passwordRegex = "^([!@#$%^&*()-=+A-Za-z0-9]){6,18}$"
        private let emailRegex = "^([A-Za-z0-9._-])+@[A-Za-z0-9]+\\.[a-zA-Z]{2,}$"
    }
    
    enum Action: BindableAction{
        case signUp
        case binding(BindingAction<State>)
        case errorHandling(Error)
        case duplicatedEmail
        case success
        case checkIdDuplicated
        case setIsIdDuplicated(Bool)
        case dismiss
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
                            await send(.errorHandling(afError))
                            return
                        }
                        
                        if statusCode == 409{
                            await send(.duplicatedEmail)
                        }else{
                            await send(.errorHandling(afError))
                        }
                    }
                    else{
                        await send(.success)
                    }
                }
            case .binding(\.$id):
                state.isIdDuplicated = nil
                return .none
            case .binding:
                return .none
            case .errorHandling(let error):
                state.isActivityIndicatorVisible = false
                print(error.localizedDescription)
                return .none
            case .duplicatedEmail:
                return .none
            case .success:
                return .none
            case .checkIdDuplicated:
                state.isActivityIndicatorVisible = true
                return .run{[id = state.id] send in
                    switch await userAPI.isIdDuplicated(id){
                    case .success(let result):
                        await send(.setIsIdDuplicated(result))
                    case .failure(let error):
                        await send(.errorHandling(error))
                    }
                }
            case .setIsIdDuplicated(let newValue):
                state.isActivityIndicatorVisible = false
                state.isIdDuplicated = newValue
                state.alert = VitalWinkAlertState(title: "회원가입", message: newValue ? "중복된 아이디 입니다." : "사용 가능한 아아디입니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                
                return .none
            case .dismiss:
                state.alert = nil
                return .none
            }
        }
    }
    
    @Dependency(\.userAPI) private var userAPI
}
