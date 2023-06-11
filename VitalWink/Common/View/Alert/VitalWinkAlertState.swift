//
//  VitalWinkAlertState.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/10.
//

import Foundation
import ComposableArchitecture
struct VitalWinkAlertState<Action>: Equatable{
    init(title: String, message: String, @VitalWinkAlertButtonBuilder buttons: () -> [VitalWinkAlertButtonState<Action>]){
        self.title = title
        self.buttons = buttons()
        self.message = message
    }

    let title: String
    let message: String
    let buttons: [VitalWinkAlertButtonState<Action>]
    
    static func == (lhs: VitalWinkAlertState, rhs: VitalWinkAlertState) -> Bool {
        return lhs.title == rhs.title && lhs.message == rhs.message && lhs.buttons == rhs.buttons
    }
}
