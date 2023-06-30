//
//  MetricCardView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/28.
//

import SwiftUI
import ComposableArchitecture

struct MetricCardView: View {
    init(metric: MonitoringRouter.Metric, value: String, store: StoreOf<Monitoring>){
        self.metric = metric
        self.value = value
        self.icon = Image("\(metric == .expressionAnalysis ? "expressionAnalysis" : metric.rawValue[metric.rawValue.startIndex ..< metric.rawValue.index(before:  metric.rawValue.endIndex)])_icon")
        switch metric{
        case .bpm:
            self.unit = "bpm"
        case .SpO2:
            self.unit = "%"
        case .RR:
            self.unit = "회"
        default:
            self.unit = nil
        }
        self.store = store
    }
    
    var body: some View {
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
                        Text(value)
                            .font(.notoSans(size: 35, weight: .bold))
                        if let unit = unit{
                            Text(unit)
                                .font(.notoSans(size: 14,weight: .light))
                                .foregroundColor(.gray)
                                .padding(.leading, 5)
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
                NavigationLink("", destination: MetricMonitoringView(store: store, metric: metric), isActive: $shouldShowMetricMonitoringView)
            }
    }
    
    @State private var shouldShowMetricMonitoringView = false
    private let metric: MonitoringRouter.Metric
    private let value: String
    private let icon: Image
    private let unit: String?
    private let store: StoreOf<Monitoring>
}

