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
        self
            .overlay{
                VitalWinkAlert(viewStore: ViewStore(store), dismiss: dismiss)
                    .edgesIgnoringSafeArea(.bottom)
            }
        
        
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


