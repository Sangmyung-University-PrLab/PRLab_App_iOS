//
//  MeasurmentResultColumnView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/27.
//

import SwiftUI

struct MeasurmentResultColumnView<Value: Numeric>: View {
    init(metric: String, value: Value, width: CGFloat){
        self.metric = metric
        self.value = value
        self.width = width
    }
    
    var body: some View {
        VStack(spacing:0){
            Divider()
            Spacer()
            HStack(spacing:0){
                Text(metric)
                    .frame(width: width)
                Text(String(describing: value))
                    .frame(width: width)
            }
            .font(.notoSans(size: 14))
            Spacer()
            Divider()
        }
    }
    
    private let metric: String
    private let value: Value
    private let width: CGFloat
}


