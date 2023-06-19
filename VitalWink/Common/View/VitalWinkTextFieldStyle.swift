//
//  LoginViewTextFieldStyle.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/07.
//

import Foundation
import SwiftUI

struct VitalWinkTextFieldStyle: TextFieldStyle{
    init(isDisabled: Bool = false){
        self.isDisabled = isDisabled
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .disabled(isDisabled)
            .font(.notoSans(size: 14, weight: .regular))
            .autocorrectionDisabled(false)
            .autocapitalization(.none)
            .padding(.vertical, 10)
            .padding(.leading, 15)
            .background(Color.white
                .onTapGesture {
                isFocused = true
            })
            .frame(height:40)
            .cornerRadius(8)
            .overlay{
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? .blue : .clear, lineWidth: 1)
            }
            .focused($isFocused)
            .animation(.spring(), value: isFocused)
    }

    private var isDisabled: Bool
    @FocusState private var isFocused
}
