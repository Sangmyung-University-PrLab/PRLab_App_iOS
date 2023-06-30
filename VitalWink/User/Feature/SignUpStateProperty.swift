//
//  SignUpViewProperty.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/19.
//

import Foundation
import ComposableArchitecture

struct SignUpStateProperty: Equatable{
    var id = ""
    var password = ""
    var repeatPassword = ""
    var email = ""
    var gender: UserModel.Gender = .man
    var birthday = Date.now
    
    //Valid
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
    var isIdDuplicated = true
    
    //Disabled
    var isEmailTexFieldDisabled: Bool{
        !(type == .general) && !email.isEmpty
    }
    
    var isSignUpButtonDisabled: Bool{
        !fieldsAreNotEmpty || !fieldsAreValid || isIdDuplicated
    }
    
    //View
    var isActivityIndicatorVisible = false
    var shouldViewDismiss: Bool = false
    var alertState: VitalWinkAlertMessageState<SignUp.Action>?
    
    let idRegex: String
    let passwordRegex: String
    let emailRegex: String
    let type: UserModel.`Type`
    
    //private
    private var fieldsAreNotEmpty: Bool{
        !(id.isEmpty || password.isEmpty || repeatPassword.isEmpty || email.isEmpty)
    }
    private var fieldsAreValid: Bool{
        isIdValid && isPasswordValid && isRepeatPasswordValid && isEmailValid
    }
}
