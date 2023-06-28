//
//  VitalWinkContentAlertState.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/27.
//

import Foundation
import SwiftUI
struct VitalWinkContentAlertState<Content, Action>: VitalWinkAlertState where Content: View{
    let content: Content
    let buttons: [VitalWinkAlertButtonState<Action>]
    
    init(@VitalWinkAlertButtonBuilder buttons: () -> [VitalWinkAlertButtonState<Action>], @ViewBuilder content: () -> Content){
        self.buttons = buttons()
        self.content = content()
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    private let id = UUID()
}
