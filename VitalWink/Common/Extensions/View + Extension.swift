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
    func vitalWinkAlert<VAS>(_ store: Store<VAS?, VAS.Action>, dismiss: VAS.Action) -> some View where VAS: VitalWinkAlertState{
        self
            .overlay{
                VitalWinkAlert(viewStore: ViewStore(store), dismiss: dismiss)
                    .edgesIgnoringSafeArea(.bottom)
            }
    }
    func hideKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    func activityIndicator(isVisible: Bool) -> some View{
        self
            .overlay{
                if isVisible{
                    ZStack{
                        Color.black.opacity(0.3)
                        ProgressView()
                            .controlSize(.large)
                            .tint(.white)
                    }.ignoresSafeArea()
                }
            }
    }
}


