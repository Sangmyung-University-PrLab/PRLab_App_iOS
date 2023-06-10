//
//  Extension.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/09.
//

import Foundation
import SwiftUI
import ComposableArchitecture
extension View{
    func vitalWinkAlert<Action>(_ store: Store<VitalWinkAlertState<Action>?, Action>, dismiss: Action) -> some View{
        ZStack{
            self
            VitalWinkAlert(viewStore: ViewStore(store), dismiss: dismiss)
        }.ignoresSafeArea()
    }
}


