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
        var id = ""
        @BindingState var password = ""
        @BindingState var repeatPassword = ""
        @BindingState var email = ""
        @BindingState var gender: UserModel.Gender = .man
        @BindingState var birthday = Date.now
        
        var isSignUpButtonDisabled: Bool{
            !fieldsAreNotEmpty || !fieldsAreValid || isIdDuplicated
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
        
        fileprivate(set) var isIdDuplicated = true
        fileprivate(set) var alertState: VitalWinkAlertState<Action>? = nil
        fileprivate(set) var isActivityIndicatorVisible = false
        fileprivate(set) var shouldSignUpViewDismiss: Bool = false
        
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
        case alertDismiss
        case idChanged(String)
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
            case .binding:
                return .none
            case .errorHandling(let error):
                state.isActivityIndicatorVisible = false
                print(error.localizedDescription)
                return .none
            case .duplicatedEmail:
                state.alertState = VitalWinkAlertState(title: "회원가입", message: "중복된 이메일입니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                return .none
            case .success:
                state.shouldSignUpViewDismiss = true
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
                state.alertState = VitalWinkAlertState(title: "회원가입", message: newValue ? "중복된 아이디 입니다." : "사용 가능한 아아디입니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                
                return .none
            case .alertDismiss:
                state.alertState = nil
                return .none
            case .idChanged(let newValue):
                if state.id != newValue{
                    state.isIdDuplicated = true
                }
                
                state.id = newValue
                
                return .none
            }
        }
    }
    
    @Dependency(\.userAPI) private var userAPI
}
