//
//  VitalWinkAlertState.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/27.
//
import ComposableArchitecture
import Foundation
import SwiftUI
protocol VitalWinkAlertState: Equatable{
    associatedtype Action
    associatedtype Content: View
    
    var buttons: [VitalWinkAlertButtonState<Self.Action>] {get}
    @ViewBuilder var content: Self.Content {get}
}
