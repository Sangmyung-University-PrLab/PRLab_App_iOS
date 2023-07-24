//
//  VitalWinkAlertPlainButtonStyle.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/12.
//

import Foundation
import SwiftUI
struct VitalWinkAlertPlainButtonStyle: ButtonStyle{
   
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.notoSans(size: 16,weight: .bold))
            .frame(maxWidth:.infinity)
            .padding(.vertical,16)
            .foregroundColor(configuration.isPressed ? .black.opacity(0.7) : .black)
            .background(.white)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1),radius: 2.5)
            .animation(.easeIn(duration: 0.1), value: configuration.isPressed)
  
    }
  
}
