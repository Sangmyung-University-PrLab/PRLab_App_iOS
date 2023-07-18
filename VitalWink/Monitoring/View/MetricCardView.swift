//
//  MetricCardView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/28.
//

import SwiftUI
import ComposableArchitecture

struct MetricCardView: View {
    init(metric: Metric, store: StoreOf<Monitoring>){
        self.metric = metric
        self.icon = Image("\(metric == .expressionAnalysis ? "expressionAnalysis" : metric.rawValue[metric.rawValue.startIndex ..< metric.rawValue.index(before:  metric.rawValue.endIndex)])_icon")
        self.store = store
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
    }
    
    var body: some View {
        WithViewStore(store, observe: {$0.recentData}){viewStore in
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.white)
                .frame(width:280, height: 100)
                .overlay{
                    VStack(spacing:10){
                        HStack(spacing:0){
                            Text(metric.korean)
                                .font(.notoSans(size: 14, weight: .bold))
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 10))
                        }
                        HStack(spacing:0){
                            if metric == .expressionAnalysis || metric == .bloodPressure{
                                HStack(spacing: 5){
                                    Text(metric == .expressionAnalysis ? "분노지수" : "수축기")
                                        .font(.notoSans(size: 12, weight: .medium))
                                    
                                    Text(numberFormatter.string(for: metric == .expressionAnalysis ? viewStore.state?.expressionAnalysis?.arousal : viewStore.state?.bloodPressure?.SYS) ?? "")
                                        .font(.notoSans(size: 20, weight: .bold))
                                        .padding(.trailing, 5)
                                    
                                    Text(metric == .expressionAnalysis ? "긴장도" : "이완기")
                                        .font(.notoSans(size: 12, weight: .medium))
                                    
                                    Text(numberFormatter.string(for: metric == .expressionAnalysis ? viewStore.state?.expressionAnalysis?.valence : viewStore.state?.bloodPressure?.DIA) ?? "")
                                        .font(.notoSans(size: 20, weight: .bold))
                                }
                            }
                        
                            else{
                                Text(value)
                                    .font(.notoSans(size: 35, weight: .bold))
                                if let unit = metric.unit{
                                    Text(unit)
                                        .font(.notoSans(size: 14,weight: .light))
                                        .foregroundColor(.gray)
                                        .padding(.leading, 5)
                                }
                            }
                            
                            Spacer()
                            icon
                                .resizable()
                                .frame(width:40, height: 40)
                        }
                    }
                    .padding(.horizontal,20)
                }
                .onTapGesture {
                    shouldShowMetricMonitoringView = true
                }
                .background{
                    NavigationLink("", destination: MetricMonitoringView(store: store.scope(state: \.metricChart, action: Monitoring.Action.metricChart), metric: metric), isActive: $shouldShowMetricMonitoringView)
                }
                .onChange(of: viewStore.state){
                    switch metric{
                    case .BMI:
                        value = numberFormatter.string(for: $0?.BMI) ?? ""
                    case .RR:
                        value = numberFormatter.string(for: $0?.RR) ?? ""
                    case .SpO2:
                        value = numberFormatter.string(for: $0?.SpO2) ?? ""
                    case .stress:
                        value = numberFormatter.string(for: $0?.stress) ?? ""
                    case .bpm:
                        value = numberFormatter.string(for: $0?.bpm) ?? ""
                    case .bloodSugars:
                        value = numberFormatter.string(for: $0?.bloodSugar) ?? ""
                    default:
                        break
                    }
                }
        }
        
    }
    @State private var value: String = ""
    @State private var shouldShowMetricMonitoringView = false
    private let metric: Metric
    private let numberFormatter: NumberFormatter
    private let icon: Image
    private let store: StoreOf<Monitoring>
}

