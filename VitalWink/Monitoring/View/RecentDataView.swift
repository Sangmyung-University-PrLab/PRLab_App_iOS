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
                    MetricCardView(metric: .bpm, store: store)
                    MetricCardView(metric: .SpO2, store: store)
                    MetricCardView(metric: .RR, store: store)
//                    MetricCardView(metric: .stress, value: "\(viewStore.state?.stress ?? 0)",  store: store)
                    MetricCardView(metric: .expressionAnalysis , store: store)
    //                MetricCardView(metric: "혈당", value: "76", icon: Image("bpm_icon"))
    //                MetricCardView(metric: "혈압", value: "76", icon: Image("bpm_icon"))
                    MetricCardView(metric: .BMI, store: store)
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
