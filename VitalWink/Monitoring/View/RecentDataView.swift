//
//  RecentDataView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/28.
//

import SwiftUI

struct RecentDataView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(spacing:20){
                MetricCardView(metric: "심박수", value: "76", icon: Image("bpm_icon"), unit:"bpm")
                MetricCardView(metric: "산소포화도", value: "99", icon: Image("spo2_icon"), unit: "%")
                MetricCardView(metric: "스트레스", value: "10", icon: Image("stress_icon"))
                MetricCardView(metric: "분당 호흡 수", value: "10", icon: Image("rr_icon"), unit: "회")
                MetricCardView(metric: "표정분석", value: "76", icon: Image("expression_icon"))
//                MetricCardView(metric: "혈당", value: "76", icon: Image("bpm_icon"))
//                MetricCardView(metric: "혈압", value: "76", icon: Image("bpm_icon"))
                MetricCardView(metric: "BMI", value: "76", icon: Image("bmi_icon"))
            }.frame(maxWidth:.infinity)
        }.background(Color.backgroundColor)
    }
}

struct RecentDataView_Previews: PreviewProvider {
    static var previews: some View {
        RecentDataView()
    }
}
