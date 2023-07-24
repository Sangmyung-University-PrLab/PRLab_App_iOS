//
//  MetricMonitoring.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/30.
//

import SwiftUI
import ComposableArchitecture

struct MetricMonitoringView: View{
    init(store: StoreOf<MetricChart>, metric: Metric, formatter: NumberFormatter? = nil){
        self.store = store
        self.metric = metric
        
        if let formatter = formatter{
            self.formatter = formatter
        }else{
            self.formatter = NumberFormatter()
            self.formatter.numberStyle = .decimal
            self.formatter.maximumFractionDigits = 2
        }
    }
    var body: some View {
        WithViewStore(store, observe: {$0}){viewStore in
            ScrollView(showsIndicators: false){
                VStack{
                    CircularSegmentedPickerView(selected: viewStore.binding(\.$period), texts: ["1주","1개월","1년"])
                        .padding(.horizontal, 5)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.white)
                        .frame(height: 255)
                        .overlay{
                            if metric == .SpO2 || metric == .bloodPressure || metric == .bloodSugars{
                                MetricStepChartView(store: store, metric: metric){
                                    if $0.isEmpty{
                                        return []
                                    }
                                    
                                    if metric == .SpO2{
                                        return [Step.SpO2(value: $0[0])]
                                    }
                                    else if metric == .bloodSugars{
                                        return [Step.bloodSugar(value: $0[0])]
                                    }
                                    else{
                                        return Step.bloodPressure(SYS: $0[0], DIA: $0[1])
                                    }
                                    
                                    
                                 
                                }.padding(.horizontal,20)
                                .padding(.vertical, 20)
                            }
                            else{
                                MetricRangeChartView(store: store, metric: metric)
                                    .padding(.horizontal,20)
                                    .padding(.vertical, 20)
                            }
                            
                        }
                    if let selected = viewStore.selected, !viewStore.datas[selected, default: []].isEmpty{
                        let datas = viewStore.datas[selected, default: []]
                        ForEach(0 ..< datas.count, id:\.self){
                            MinMaxCardView(data: datas[$0].value, metric: metric, formatter: formatter)
                        }

                        if metric == .expressionAnalysis, !viewStore.expressions[selected, default: [:]].isEmpty{
                            let expressions = viewStore.expressions[selected, default: [:]]
                            
                            PieChartView(expressions: expressions, numberFormatter: formatter)
                                .frame(height: UIApplication.shared.screenSize?.width ?? 0)
                                .padding(.bottom, 20)
                                .background{
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(.white)
                                }
                                
                        }
                    }
                    Spacer()
                    
                }
            }.padding(.horizontal, 20)
            .background(Color.backgroundColor)
            .navigationTitle("\(metric.korean)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar{
               VitalWinkBackButton()
            }
            .onDisappear{
                viewStore.send(.onDisappear)
            }
            .activityIndicator(isVisible: viewStore.isLoading)
            .vitalWinkAlert(store.scope(state: \.alertState, action: {$0}), dismiss: .alertDismiss)
        }
        
    }
    
    
 
    @Environment(\.dismiss) private var dismiss
    private let store: StoreOf<MetricChart>
    private let metric: Metric
    private let formatter: NumberFormatter
}

//struct MetricMonitoring_Previews: PreviewProvider {
//    static var previews: some View {
//        
////        MetricMonitoringView(store: Store(initialState: MetricChart.State(), reducer: MetricChart()), metric: .bpm)
//    }
//}
