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
struct MetricRangeChartView: View{
    init(store: StoreOf<MetricChart>, metric: Metric){
        self.store = store
        self.metric = metric
        
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
    }
    
    var body: some View{
        WithViewStore(store, observe: {$0}){viewStore in
            VStack(alignment: .trailing){
                if metric == .expressionAnalysis || metric == .bloodPressure{
                    HStack(spacing:5){
                        Capsule()
                            .frame(width: 5, height: 10)
                            .foregroundColor(.blue)
                        Text(metric == .expressionAnalysis ? "긴장도" : "수축기")
                            .padding(.trailing, 5)
                        Capsule()
                            .frame(width: 5, height: 10)
                            .foregroundColor(.red)
                        Text(metric == .expressionAnalysis ? "분노지수" : "이완기")
                    }.font(.notoSans(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                
                GeometryReader{proxy in
                    let itemWidth = (proxy.size.width - 50) / CGFloat(viewStore.period.numberOfItem)
                    HStack(spacing:10){
                        ScrollView(.horizontal,showsIndicators: false){
                            LazyHStack(spacing: 10){
                                ForEach(viewStore.sortedKeys, id: \.self){key in
                                    MetricRangeChartItemView(x:viewStore.xs[key,default:""],y: viewStore.datas[key, default: []].map{$0.value}, baseRange: viewStore.baseRange, baseHeight: proxy.size.height - 30)
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
                            if let baseRange = viewStore.baseRange{
                                Text(numberFormatter.string(for: baseRange.max)!)
                                Spacer()
                                Text(numberFormatter.string(for: baseRange.min)!)
                            }
                            Spacer().frame(height:30)
                        }.font(.notoSans(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity, maxHeight:proxy.size.height + 12)
                    }
                    .fixedSize()
                   
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
    private let numberFormatter: NumberFormatter
    
}

struct MetricRangeChartItemView: View{
    init(x:String, y: [MinMaxType<Float>], baseRange: MinMaxType<Float>?, baseHeight: CGFloat) {
        self.baseRange = baseRange
        self.x = x
        self.y = y
        if let baseRange = baseRange{
            self.ratio = (baseRange.max - baseRange.min) / Float(baseHeight)
        }
        else{
            self.ratio = 1
        }
        
        self.baseHeight = baseHeight
    }
    
    var body: some View{
        VStack(spacing:0){
            if !y.isEmpty {
                HStack{
                    ForEach(0 ..< y.count, id: \.self){index in
                        VStack(spacing: 0){
                            let value = y[index]
                            if let baseRange = self.baseRange{
                                if baseRange.min == baseRange.max{
                                    Capsule()
                                        .frame(maxWidth: 5, minHeight:3)
                                }
                                else{
                                    let upper = max(baseRange.max - value.max, 0)
                                    let lower = max(value.min - baseRange.min,0)
                                    
                                    if upper != 0{
                                        Spacer()
                                            .frame(height: CGFloat(upper / ratio))
                                        
                                    }
                                    Capsule()
                                        .frame(maxWidth: 5, minHeight:3)
                                    
                                    
                                    if lower != 0 && value.min != value.max{
                                        Spacer()
                                            .frame(height:CGFloat(lower / ratio))
                                    }
                                    else if value.max == value.min && value != baseRange{
                                        Spacer()
                                            .frame(height: max(baseHeight - CGFloat(upper / ratio) - 4, 0))
                                    }
                                }
                            }
                            else{
                                Capsule()
                                    .frame(maxWidth: 5, minHeight:3)
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
    
    private let ratio: Float
    private let x: String
    private let y: [MinMaxType<Float>]
    private let baseRange: MinMaxType<Float>?
    private let baseHeight: CGFloat
}
