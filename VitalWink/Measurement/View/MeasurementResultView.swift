//
//  MeasurementResultView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/26.
//

import SwiftUI

struct MeasurementResultView: View {
    var body: some View {
        GeometryReader{proxy in
            List{
                Section{
                    MeasurmentResultColumnView(metric: "심박수", value: 0, width: proxy.size.width / 2)
                    MeasurmentResultColumnView(metric: "산소포화도", value: 0, width: proxy.size.width / 2)
                    MeasurmentResultColumnView(metric: "호흡수", value: 0, width: proxy.size.width / 2)
                    MeasurmentResultColumnView(metric: "스트레스", value: 0, width: proxy.size.width / 2)
                    MeasurmentResultColumnView(metric: "BMI", value: 0, width: proxy.size.width / 2)
                    MeasurmentResultColumnView(metric: "긴장도", value: 0, width: proxy.size.width / 2)
                    MeasurmentResultColumnView(metric: "분노지수", value: 0, width: proxy.size.width / 2)
                }header: {
                    HStack(spacing:0){
                        Text("지표") .frame(width: proxy.size.width / 2)
                        Text("값") .frame(width: proxy.size.width / 2)
                    }
                    .font(.notoSans(size: 14))
                    .padding(.vertical, 10)
                    .foregroundColor(.black)
                    .background(Color.backgroundColor)
                }
                .listRowInsets(EdgeInsets(top:0, leading: 0, bottom: 0, trailing: 0))
            }
        }
        .listStyle(.inset)
        
    }
}

struct MeasurementResultView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementResultView()
    }
}
