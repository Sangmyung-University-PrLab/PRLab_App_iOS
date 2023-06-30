//
//  MetricMonitoring.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/30.
//

import SwiftUI
import ComposableArchitecture

struct MetricMonitoringView: View{
    let demoData = [
        MinMaxType<Float>(min: 70.0, max: 82.0),
        MinMaxType<Float>(min: 93.0, max: 108.0),
        MinMaxType<Float>(min: 123.0, max: 138.0),
        MinMaxType<Float>(min: 64.0, max: 73.0),
        MinMaxType<Float>(min: 87.0, max: 95.0),
        MinMaxType<Float>(min: 61.0, max: 65.0),
        MinMaxType<Float>(min: 64.0, max: 73.0),
        MinMaxType<Float>(min: 87.0, max: 95.0),
        MinMaxType<Float>(min: 61.0, max: 65.0),
        MinMaxType<Float>(min: 64.0, max: 73.0),
        MinMaxType<Float>(min: 87.0, max: 95.0),
        MinMaxType<Float>(min: 61.0, max: 65.0),
        MinMaxType<Float>(min: 64.0, max: 73.0),
        MinMaxType<Float>(min: 87.0, max: 95.0),
        MinMaxType<Float>(min: 61.0, max: 65.0),
        MinMaxType<Float>(min: 64.0, max: 73.0),
        MinMaxType<Float>(min: 87.0, max: 95.0),
        MinMaxType<Float>(min: 61.0, max: 65.0),
        MinMaxType<Float>(min: 64.0, max: 73.0),
        MinMaxType<Float>(min: 87.0, max: 95.0),
        MinMaxType<Float>(min: 61.0, max: 65.0),
        MinMaxType<Float>(min: 64.0, max: 73.0),
        MinMaxType<Float>(min: 87.0, max: 95.0),
        MinMaxType<Float>(min: 61.0, max: 65.0),
        MinMaxType<Float>(min: 64.0, max: 73.0),
        MinMaxType<Float>(min: 87.0, max: 95.0),
        MinMaxType<Float>(min: 61.0, max: 65.0),
        MinMaxType<Float>(min: 64.0, max: 73.0),
        MinMaxType<Float>(min: 87.0, max: 95.0),
        MinMaxType<Float>(min: 61.0, max: 65.0),
        MinMaxType<Float>(min: 64.0, max: 73.0),
        MinMaxType<Float>(min: 87.0, max: 95.0),
        MinMaxType<Float>(min: 61.0, max: 65.0),
    ]
    init(store: StoreOf<Monitoring>, metric: MonitoringRouter.Metric){
        self.store = store
        self.metric = metric
       
    }
    var body: some View {
        WithViewStore(store, observe: {$0}){viewStore in
            VStack{
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.white)
                    .frame(height: 255)
                    .overlay{
                        MetricChartView(datas:
                                            getDatas(store: viewStore)
                        )
                        .padding(.horizontal,10)
                        .padding(.vertical, 20)
                    }
                    .padding(.horizontal, 20)
                Spacer()
                
            }
            .background(Color.backgroundColor)
            .navigationTitle("\(metric.korean)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
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
            .onAppear{
                viewStore.send(.fetchMetricDatas(metric, .now))
            }
        }
    }
    
    
    func getDatas(store: ViewStore<Monitoring.State, Monitoring.Action>) -> [MetricData<MinMaxType<Float>>]{
        return store.intMetricDatas.map{
            let value = MinMaxType(min: Float($0.value.min), max: Float($0.value.max))
            return MetricData(value: value, basisDate: $0.basisDate)
        }
    }
    
    @Environment(\.dismiss) private var dismiss
    private let store: StoreOf<Monitoring>
    private let metric: MonitoringRouter.Metric
}

struct MetricMonitoring_Previews: PreviewProvider {
    static var previews: some View {
        MetricMonitoringView(store: Store(initialState: Monitoring.State(), reducer: Monitoring()), metric: .bpm)
    }
}
