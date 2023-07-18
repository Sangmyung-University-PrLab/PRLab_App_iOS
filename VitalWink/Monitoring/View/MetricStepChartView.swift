//
//  MetricCharView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/29.
//

import Foundation
import Charts
import SwiftUI
import ComposableArchitecture
struct MetricStepChartView: View{
    init(store: StoreOf<MetricChart>, metric: Metric, stepFilter: @escaping (MinMaxType<Float>) -> Step){
        self.store = store
        self.metric = metric
        self.stepFilter = stepFilter
    }
    
    var body: some View{
        WithViewStore(store, observe: {$0}){viewStore in
            VStack(alignment: .trailing){
                GeometryReader{proxy in
                    let itemWidth = (proxy.size.width - 50) / CGFloat(viewStore.period.numberOfItem)
                    HStack(spacing:10){
                        ScrollView(.horizontal,showsIndicators: false){
                            LazyHStack(spacing: 10){
                                ForEach(viewStore.sortedKeys, id: \.self){key in
                                    MetricStepChartItemView(x: viewStore.xs[key,default:""], step: viewStore.datas[key, default: []].map{self.stepFilter($0.value)}, baseHeight: proxy.size.height - 30)
                                        .frame(width:itemWidth)
                                        .scaleEffect(x:-1,y:1)
                                        .onAppear{
                                            viewStore.send(.changeVisible(key,true))
                                            guard let earliestDate = viewStore.sortedKeys.last else{
                                                return
                                            }
                                            if earliestDate == key {
                                                viewStore.send(.fetchMetricDatas(metric, earliestDate))
                                            }
                                        }
                                        .onDisappear{
                                            viewStore.send(.changeVisible(key,false))
                                        }
                                        .onTapGesture{
                                            viewStore.send(.selectItem(key))
                                        }
                                        .opacity(viewStore.selected == key ? 1 : 0.3)
                                }
                            }
                        }
                        .scaleEffect(x:-1,y:1)
                        .frame(width: proxy.size.width - 30)
                        .overlay{
                            Path{
                                $0.move(to: CGPoint(x:0, y:proxy.size.height - 30))
                                $0.addLine(to: CGPoint(x:proxy.size.width - 30, y: proxy.size.height - 30))
                                $0.addLine(to: CGPoint(x:proxy.size.width - 30, y: 0))
                            }.stroke(Color.gray)
                            
                        }.disabled(viewStore.isLoading)
                        
                        VStack(spacing: 0){
                                Text("상")
                                Spacer()
                                Text("중")
                                Spacer()
                                Text("하")
                            Spacer().frame(height:30)
                        }.font(.notoSans(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity, maxHeight:proxy.size.height + 12)
                    }
//                    .fixedSize()
                   
                }
            }.onChange(of: viewStore.period){_ in
                viewStore.send(.fetchMetricDatas(metric))
            }
            .onAppear{
                viewStore.send(.fetchMetricDatas(metric))
            }
            
        }
    }
    
    private let metric: Metric
    private let store: StoreOf<MetricChart>
    private let stepFilter: (MinMaxType<Float>) -> Step
    
    
}

struct MetricStepChartItemView: View{
    init(x:String, step: [Step], baseHeight: CGFloat) {
        self.x = x
        self.step = step
        self.baseHeight = baseHeight
    }
     
    var body: some View{
        VStack(spacing:0){
            if !step.isEmpty {
                HStack{
                    ForEach(0 ..< step.count, id: \.self){index in
                        VStack(spacing: 0){
                            if step[index] != .high{
                                Spacer()
                                    .frame(height: step[index] == .low ? self.baseHeight / 2 : self.baseHeight / 4)
                            }
                            
                            Capsule()
                                .frame(maxWidth: 5, maxHeight: self.baseHeight / 2)
                            
                            if step[index] != .low{
                                Spacer()
                                    .frame(height: step[index] == .high ? self.baseHeight / 2 : self.baseHeight / 4)
                            }
                        }
                        .foregroundColor(index == 0 ? .blue : .red)
                        
                    }
                }.frame(height: baseHeight)
                
            }
            else{
                Spacer()
                    .frame(height: baseHeight)
            }
            Text(x)
                .font(.notoSans(size: 10))
                .foregroundColor(.gray)
                .padding(.top, 10)
                .frame(height:30)
        }
    }
    
  
    private let x: String
    private let step: [Step]
    private let baseHeight: CGFloat
}
