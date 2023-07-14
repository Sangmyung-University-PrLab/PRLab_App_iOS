//
//  VitalWinkBackButton.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/14.
//

import SwiftUI

struct VitalWinkBackButton: ToolbarContent{
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading){
            Image(systemName: "chevron.backward")
                .font(.system(size:15))
                .contentShape(Rectangle())
                .frame(width: 25, height: 25)
                .onTapGesture {
                    dismiss()
                }
        }
    }
    
    @Environment(\.dismiss) private var dismiss
}

