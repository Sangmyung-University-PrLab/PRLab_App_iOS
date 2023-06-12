//
//  VitialWinkFormSection.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/11.
//

import Foundation
import SwiftUI

struct VitalWinkFormSection<Content>: View where Content: View{
    init(header: String, errorMessage: String? = nil, content: () -> Content){
        self.header = header
        self.content = content()
        self.errorMessage = errorMessage
    }
    
    var body: some View{
        VStack(alignment:.leading, spacing:0){
            Text(header)
                .font(.notoSans(size: 14, weight: .medium))
                .foregroundColor(.black)
                .padding(.bottom, 10)
       
            content.padding(.bottom, 5)

            Text(errorMessage ?? "")
           .font(.notoSans(size: 13, weight: .light))
           .foregroundColor(.red)
        }
    }
    
    
    private let header: String
    private let content: Content
    private let errorMessage: String?
    
}
