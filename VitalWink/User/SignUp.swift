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
        init(_ type: UserModel.`Type`,idRegex: String, passwordRegex: String, emailRegex: String){
            property = SignUpStateProperty(idRegex: idRegex, passwordRegex: passwordRegex, emailRegex: emailRegex, type: type)
        }
      
        fileprivate(set) var property: SignUpStateProperty
    }
    
    enum Action{
        case signUp
        case errorHandling(Error)
        case duplicatedEmail
        case success
        case checkIdDuplicated
        case setIsIdDuplicated(Bool)
        case alertDismiss
        case onDisappear
        case onAppear
        case dismiss
        case responseUserModel(UserModel)
        
        
        case idChanged(String)
        case passwordChanged(String)
        case repeatPasswordChanged(String)
        case emailChanged(String)
        case birthdayChanged(Date)
        case genderChanged(UserModel.Gender)
    }
    
    var body: some ReducerProtocol<State, Action>{
        Reduce{state, action in
            switch action{
            case .signUp:
                let user = UserModel(id: state.property.id, password: state.property.password, email: state.property.email, gender: state.property.gender, birthday: state.property.birthday, type:.general)
                
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

            case .errorHandling(let error):
                state.property.isActivityIndicatorVisible = false
                
                let message = error.localizedDescription
                os_log(.error, log:.signUp,"%@", message)
                
                state.property.alertState = VitalWinkAlertState(title: "회원가입", message: "회원가입 중 오류가 발생하였습니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                return .none
            case .duplicatedEmail:
                state.property.alertState = VitalWinkAlertState(title: "회원가입", message: "중복된 이메일입니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                return .none
            case .success:
                state.property.alertState = VitalWinkAlertState(title: "회원가입", message: "회원가입이 완료되었습니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return .dismiss
                    }
                }
                
                return .none
            case .checkIdDuplicated:
                state.property.isActivityIndicatorVisible = true
                return .run{[id = state.property.id] send in
                    switch await userAPI.isIdDuplicated(id){
                    case .success(let result):
                        await send(.setIsIdDuplicated(result))
                    case .failure(let error):
                        await send(.errorHandling(error))
                    }
                }
            case .setIsIdDuplicated(let newValue):
                state.property.isActivityIndicatorVisible = false
                state.property.isIdDuplicated = newValue
                state.property.alertState = VitalWinkAlertState(title: "회원가입", message: newValue ? "중복된 아이디 입니다." : "사용 가능한 아아디입니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                
                return .none
            case .alertDismiss:
                state.property.alertState = nil
                return .none
            case .idChanged(let newValue):
                if state.property.id != newValue{
                    state.property.isIdDuplicated = true
                }
                state.property.id = newValue
                
                return .none
            case .dismiss:
                state.property.shouldViewDismiss = true
                return .none
            case .onDisappear:
                state = State(state.property.type, idRegex: state.property.idRegex, passwordRegex: state.property.passwordRegex, emailRegex: state.property.emailRegex)
                return .none
            case .onAppear:
                if state.property.type != .general{
                    state.property.isActivityIndicatorVisible = true
                    return .run{[type = state.property.type] send in
                        switch await snsUserInfoService.getSnsUserInfo(type){
                        case .success(let user):
                            await send(.responseUserModel(user))
                        case .failure(let error):
                            await send(.errorHandling(error))
                        }
                    }
                }
                else{
                    return .none
                }
            case .responseUserModel(let user):
                state.property.email = user.email
                state.property.birthday = user.birthday
                state.property.gender = user.gender
                state.property.isActivityIndicatorVisible = false
                return .none
                
            case .passwordChanged(let password):
                state.property.password = password
                return .none
            case .emailChanged(let email):
                state.property.email = email
                return .none
            case .repeatPasswordChanged(let repeatPassword):
                state.property.repeatPassword = repeatPassword
                return .none
            case .birthdayChanged(let birthday):
                state.property.birthday = birthday
                return .none
            case .genderChanged(let gender):
                state.property.gender = gender
                return .none
            }
        }
    }
    
    private let snsUserInfoService = SnsUserInfoService()
    @Dependency(\.userAPI) private var userAPI
    
}
