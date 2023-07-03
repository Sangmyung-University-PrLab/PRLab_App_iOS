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
            VStack{
                CircularSegmentedPickerView(selected: viewStore.binding(\.$period), texts: ["1일", "1주","1개월","1년"])
                    .padding(.horizontal, 5)
                
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.white)
                    .frame(height: 255)
                    .overlay{
                        MetricChartView(store: store, metric: metric)
                        .padding(.horizontal,10)
                        .padding(.vertical, 20)
                    }
                
                if let selected = viewStore.selected {
                    MinMaxCardView(data: viewStore.datas[selected].value, metric: metric, formatter: formatter)
                }
               
                
                Spacer()
                
            }
            .padding(.horizontal, 20)
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
           
        }
    }
    
    
 
    @Environment(\.dismiss) private var dismiss
    private let store: StoreOf<MetricChart>
    private let metric: Metric
    private let formatter: NumberFormatter
}

struct MetricMonitoring_Previews: PreviewProvider {
    static var previews: some View {
//        MetricMonitoringView(store: Store(initialState: MetricChart.State(), reducer: MetricChart()), metric: .bpm)
        let value = MinMaxType(min: 40, max: 75)
        
        GeometryReader{proxy in
            Capsule()
                .foregroundColor(.blue.opacity(0.3))
                .frame(height: 5)
                .padding(.horizontal, 10)
                .overlay(alignment:.leading){
                    let inndexCapsuleWidth = proxy.size.width * CGFloat(Float(value.max - value.min) / (Metric.bpm.max - Metric.bpm.min))
                    Capsule()
                        .foregroundColor(.blue)
                        .frame(width: inndexCapsuleWidth)
                        .offset(x: CGFloat((Float(value.min) - Metric.bpm.min) / (Metric.bpm.max - Metric.bpm.min)) * proxy.size.width)
                        
                }.onAppear{
                    print((Float(value.min) - Metric.bpm.min) / (Metric.bpm.max - Metric.bpm.min))
                }
        }.frame(width: 300,height:5)
            
    }
}
