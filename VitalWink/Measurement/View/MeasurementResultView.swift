//
//  MeasurementResultView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/26.
//

import SwiftUI

struct MeasurementResultView: View {
    var body: some View {
        VStack(spacing:0){
            Text("측정 결과")
                .font(.notoSans(size: 16, weight: .medium))
                .padding(.bottom, 10)
                .padding(.top, 25)
            MeasurmentResultColumnView(metric: "지표", value: "값")
                .background(Color.backgroundColor.ignoresSafeArea([]))
            MeasurmentResultColumnView(metric: "심박수", value: "\(0)")
            MeasurmentResultColumnView(metric: "산소포화도", value: "\(0)")
            MeasurmentResultColumnView(metric: "호흡수", value: "\(0)")
            MeasurmentResultColumnView(metric: "스트레스", value: "\(0)")
            MeasurmentResultColumnView(metric: "BMI", value: "\(0)")
            MeasurmentResultColumnView(metric: "긴장도", value: "\(0)")
            MeasurmentResultColumnView(metric: "분노지수", value: "\(0)")
            Spacer()
        }.frame(height:403)
        
    }
}

struct MeasurementResultView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementResultView()
    }
}
