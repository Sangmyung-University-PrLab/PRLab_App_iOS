//
//  MeasurementResultView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/26.
//

import SwiftUI

struct MeasurementResultView: View {
    init(_ result:MeasurementResult){
        self.result = result
    }
    
    var body: some View {
        VStack(spacing:0){
            Text("측정 결과")
                .font(.notoSans(size: 16, weight: .bold))
                .padding(.bottom, 10)
                .padding(.top, 25)
            
            Group{
                MeasurmentResultColumnView(metric: "지표", value: "값")
                    .background(Color.backgroundColor.ignoresSafeArea([]))
                MeasurmentResultColumnView(metric: "심박수", value: "\(result.bpm)")
                MeasurmentResultColumnView(metric: "산소포화도", value: Step.SpO2(value: Float(result.SpO2)).korean)
                MeasurmentResultColumnView(metric: "호흡수", value: "\(result.RR)")
//                MeasurmentResultColumnView(metric: "스트레스", value: "\(result.stress)")
        
                if let BMI = result.BMI{
                    
                    MeasurmentResultColumnView(metric: "BMI", value: "\(Step.BMI(value: Float(BMI)) == .normal ? "정상" : Step.BMI(value:Float(BMI)) == .caution ? "저체중" : "과체중 이상")(\(BMI))")
                }
                if let arousal = result.expressionAnalysis?.arousal{
                    MeasurmentResultColumnView(metric: "긴장도", value: String(format: "%.2f", arousal))
                }
                if let valence = result.expressionAnalysis?.valence{
                    MeasurmentResultColumnView(metric: "분노지수", value: String(format: "%.2f", valence))
                }
                if let bloodPressure = result.bloodPressure {
                    MeasurmentResultColumnView(metric: "혈압:수축기", value: Step.bloodPressure(SYS: Float(bloodPressure.SYS)).korean)
                    MeasurmentResultColumnView(metric: "혈압:이완기", value: Step.bloodPressure(DIA: Float(bloodPressure.DIA)).korean)
                }
//                if let bloodSugar = result.bloodSugar{
//                    MeasurmentResultColumnView(metric: "혈당", value: "\(bloodSugar)")
//                }
            }
            
            Spacer()
        }.frame(height:403)
        
    }
    private let result: MeasurementResult
}
//
//struct MeasurementResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        MeasurementResultView()
//    }
//}
