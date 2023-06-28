//
//  MeasurmentResultColumnView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/27.
//

import SwiftUI

struct MeasurmentResultColumnView : View {
    init(metric: String, value: String){
        self.metric = metric
        self.value = value
    }
    
    var body: some View {
        VStack(spacing:0){
            Divider()
            
            GeometryReader{proxy in
                HStack(spacing:0){
                    Text(metric).frame(width: proxy.size.width / 2)
                    Text(value).frame(width: proxy.size.width / 2)
                }
                .font(.notoSans(size: 14))
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }.frame(height: 40)
            
            Divider()
        }.frame(height: 40)
    }
    
    private let metric: String
    private let value: String
    
}



