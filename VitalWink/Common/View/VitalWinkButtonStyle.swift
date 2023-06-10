//
//  VitalWinkAlertButton.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/09.
//

import Foundation
import SwiftUI

struct VitalWinkButtonStyle: ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth:.infinity, minHeight:40)
            .foregroundColor(configuration.isPressed ? .white.opacity(0.7) : .white)
            .font(.notoSans(size: 14,weight: .bold))
            .background(Color.blue)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1),radius: 5)
            .animation(.easeIn(duration: 0.1), value: configuration.isPressed)
    }
}



struct VitalWinkButtonStyle_Previews: PreviewProvider{
    static var previews: some View{
        Button("테스트"){
            
        }.buttonStyle(VitalWinkButtonStyle())
    }
}
