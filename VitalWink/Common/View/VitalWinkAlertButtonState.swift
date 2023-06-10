//
//  VitalWinkAlertButtonState.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/10.
//

import Foundation
struct VitalWinkAlertButtonState<Action>: Equatable, Identifiable{
    static func == (lhs: VitalWinkAlertButtonState<Action>, rhs: VitalWinkAlertButtonState<Action>) -> Bool {
        return lhs.title == rhs.title && lhs.id == rhs.id
    }
    
    let title: String
    let action: () -> Action?
    let id = UUID()
    
    
}
