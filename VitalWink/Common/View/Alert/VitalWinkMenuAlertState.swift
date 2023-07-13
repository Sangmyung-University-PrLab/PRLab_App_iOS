//
//  VitalWinkMenuAlertState.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/12.
//

import Foundation
import SwiftUI
struct VitalWinkMenuAlertState<Action>: VitalWinkAlertState{
    var content: some View{
        EmptyView()
    }
    
    init(@VitalWinkAlertButtonBuilder buttons: () -> [VitalWinkAlertButtonState<Action>]){
        self.buttons = buttons()
    }

    let buttons: [VitalWinkAlertButtonState<Action>]
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.buttons == rhs.buttons
    }
}
