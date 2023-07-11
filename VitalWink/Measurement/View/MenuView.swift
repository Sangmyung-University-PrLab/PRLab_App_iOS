//
//  MenuView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/11.
//

import Foundation
import SwiftUI

struct MenuView: View{
    var body: some View{
        VStack(spacing:10){
            menuViewButton("로그아웃")
            menuViewButton("회원탈퇴")
        }.padding(.vertical, 20)
    }
    
    
    @ViewBuilder
    func menuViewButton(_ title: String) -> some View{
        Button{
            
        }label: {
            Text(title)
                .foregroundColor(.gray)
                .font(.notoSans(size: 16,weight: .medium))
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .cornerRadius(8)
                
        }.tint(.white)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color:.black.opacity(0.1), radius:2.5)
        
    }
}

