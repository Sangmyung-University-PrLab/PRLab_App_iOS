//
//  SignUp.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/13.
//

import Foundation
import ComposableArchitecture
import OSLog

struct SignUp: ReducerProtocol{
    struct State: Equatable{
        init(idRegex: String, passwordRegex: String, emailRegex: String){
            self.idRegex = idRegex
            self.passwordRegex = passwordRegex
            self.emailRegex = emailRegex
            type = .general
        }
        
        init(user: UserModel, idRegex: String, passwordRegex: String, emailRegex: String){
            self.idRegex = idRegex
            self.passwordRegex = passwordRegex
            self.emailRegex = emailRegex
            self.email = user.email
            self.gender = user.gender
            self.birthday = user.birthday
            self.type = user.type
        }
        
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
        fileprivate(set) var shouldViewDismiss: Bool = false
        
        private var fieldsAreNotEmpty: Bool{
            !(id.isEmpty || password.isEmpty || repeatPassword.isEmpty || email.isEmpty)
        }
        private var fieldsAreValid: Bool{
            isIdValid && isPasswordValid && isRepeatPasswordValid && isEmailValid
        }
        
        fileprivate let idRegex: String
        fileprivate let passwordRegex: String
        fileprivate let emailRegex: String
        
        private let type: UserModel.`Type`
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
        case onDisappear
        case dismiss
    }
    
    var body: some ReducerProtocol<State, Action>{
        BindingReducer()
        Reduce{state, action in
            switch action{
            case .signUp:
                let user = UserModel(id: state.id, password: state.password, email: state.email, gender: state.gender, birthday: state.birthday, type:.general)
                
                return .run{ send in
                    do{
                        try await userAPI.signUp(user)
                        await send(.success)
                    }catch{
                        guard let afError = error.asAFError else{
                            await send(.errorHandling(error))
                            return
                        }
                        
                        guard afError.isResponseValidationError, let statusCode = afError.responseCode else{
                            await send(.errorHandling(afError))
                            return
                        }
                        
                        statusCode == 409 ? await send(.duplicatedEmail) : await send(.errorHandling(afError))
                    }
                    
                }
            case .binding:
                return .none
            case .errorHandling(let error):
                state.isActivityIndicatorVisible = false
                
                let message = error.localizedDescription
                os_log(.error, log:.signUp,"%@", message)
                
                state.alertState = VitalWinkAlertState(title: "회원가입", message: "회원가입 중 오류가 발생하였습니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                return .none
            case .duplicatedEmail:
                state.alertState = VitalWinkAlertState(title: "회원가입", message: "중복된 이메일입니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                return .none
            case .success:
                state.alertState = VitalWinkAlertState(title: "회원가입", message: "회원가입이 완료되었습니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return .dismiss
                    }
                }
                
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
            case .dismiss:
                state.shouldViewDismiss = true
                return .none
            case .onDisappear:
                state = State(idRegex: state.idRegex, passwordRegex: state.passwordRegex, emailRegex: state.emailRegex)
                return .none
            }
        }
    }
    
    @Dependency(\.userAPI) private var userAPI
    
}
