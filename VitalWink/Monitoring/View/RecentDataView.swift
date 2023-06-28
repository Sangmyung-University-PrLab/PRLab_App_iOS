//
//  RecentDataView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/28.
//

import SwiftUI
import ComposableArchitecture
struct RecentDataView: View {
    init(store: StoreOf<Monitoring>){
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: \.recentData){viewStore in
            ScrollView(.vertical, showsIndicators: false){
                VStack(spacing:20){
                    MetricCardView(metric: "심박수", value: "\(viewStore.state?.bpm ?? 0)", icon: Image("bpm_icon"), unit:"bpm")
                    MetricCardView(metric: "산소포화도", value: "\(viewStore.state?.SpO2 ?? 0)", icon: Image("spo2_icon"), unit: "%")
                    MetricCardView(metric: "스트레스", value: "\(viewStore.state?.stress ?? 0)", icon: Image("stress_icon"))
                    MetricCardView(metric: "분당 호흡 수", value: "\(viewStore.state?.RR ?? 0)", icon: Image("rr_icon"), unit: "회")
                    MetricCardView(metric: "표정분석", value: "\(viewStore.state?.expressionAnalysis?.arousal ?? 0)", icon: Image("expression_icon"))
    //                MetricCardView(metric: "혈당", value: "76", icon: Image("bpm_icon"))
    //                MetricCardView(metric: "혈압", value: "76", icon: Image("bpm_icon"))
                    MetricCardView(metric: "BMI", value: "\(viewStore.state?.BMI ?? 0)", icon: Image("bmi_icon"))
                }.frame(maxWidth:.infinity)
            }.background(Color.backgroundColor)
            .onAppear{
               viewStore.send(.fetchRecentData)
            }
            .navigationTitle(Text("기록"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Image(systemName: "chevron.backward")
                        .font(.system(size:15))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
        }
        
    }
    @Environment(\.dismiss) private var dismiss
    private let store: StoreOf<Monitoring>
}

struct RecentDataView_Previews: PreviewProvider {
    static var previews: some View {
        RecentDataView(store: Store(initialState: Monitoring.State(), reducer: Monitoring()))
    }
}
