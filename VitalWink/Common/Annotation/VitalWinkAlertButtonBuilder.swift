//
//  AlertButtonBuilder.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/09.
//

import Foundation
import SwiftUI
@resultBuilder
enum VitalWinkAlertButtonBuilder{
    static func buildBlock<Action>(_ components: VitalWinkAlertButtonState<Action>...) -> [VitalWinkAlertButtonState<Action>] {
        components.compactMap{$0}
    }
}
