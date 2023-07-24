//
//  VitialWinkFormSection.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/11.
//

import Foundation
import SwiftUI

struct VitalWinkFormSection<Content>: View where Content: View{
    init(header: String, errorMessage: String? = nil, shouldShowErrorMessage: Bool = false, content: () -> Content){
        self.header = header
        self.content = content()
        self.errorMessage = errorMessage
        self.shouldShowErrorMessage = shouldShowErrorMessage
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
           .foregroundColor(shouldShowErrorMessage ? .red : .clear)
        }
    }
    
    
    private let header: String
    private let content: Content
    private let errorMessage: String?
    private let shouldShowErrorMessage: Bool
}
