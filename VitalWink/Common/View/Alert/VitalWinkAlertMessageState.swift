//
//  VitalWinkAlertState.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/10.
//

import Foundation
import ComposableArchitecture
import SwiftUI
struct VitalWinkAlertMessageState<Action>: VitalWinkAlertState{
    var content: some View{
        VStack(alignment: .leading, spacing: 0){
            Text(title)
                .font(.notoSans(size: 12,weight: .medium))
                .padding(.bottom, 10)
            Divider()
                .padding(.bottom,10)
            
            Text(LocalizedStringKey(message))
                .font(.notoSans(size: 14,weight: .regular))
                .padding(.bottom, 30)
        }.padding(.top, 20)
    }
    
    init(title: String, message: String, @VitalWinkAlertButtonBuilder buttons: () -> [VitalWinkAlertButtonState<Action>]){
        self.title = title
        self.buttons = buttons()
        self.message = message
    }

    let title: String
    let message: String
    let buttons: [VitalWinkAlertButtonState<Action>]
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.title == rhs.title && lhs.message == rhs.message && lhs.buttons == rhs.buttons
    }
  
}
