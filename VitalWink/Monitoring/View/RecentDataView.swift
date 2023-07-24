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
        WithViewStore(store, observe: {$0}){viewStore in
            ScrollView(.vertical, showsIndicators: false){
                VStack(spacing:20){
                    MetricCardView(metric: .bpm, store: store)
                    MetricCardView(metric: .SpO2, store: store)
                    MetricCardView(metric: .RR, store: store)
//                    MetricCardView(metric: .stress, value: "\(viewStore.state?.stress ?? 0)",  store: store)
                    MetricCardView(metric: .expressionAnalysis , store: store)
                    MetricCardView(metric: .bloodSugars, store: store)
                    MetricCardView(metric: .bloodPressure, store: store)
                    MetricCardView(metric: .BMI, store: store)
                }.frame(maxWidth:.infinity)
            }.background(Color.backgroundColor)
            .onAppear{
               viewStore.send(.fetchRecentData)
            }
            .onDisappear{
                viewStore.send(.onDisappear)
            }
            .navigationTitle(Text("기록"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar{
                VitalWinkBackButton()
            }
            .vitalWinkAlert(store.scope(state: \.alertState, action: {$0}), dismiss: .alertDismiss)
            .activityIndicator(isVisible: viewStore.isLoading)
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
