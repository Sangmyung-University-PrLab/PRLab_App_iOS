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
struct MetricChartView: View{
    init(store: StoreOf<MetricChart>, metric: Metric){
        self.store = store
        self.metric = metric
        
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
    }
    
    var body: some View{
        WithViewStore(store, observe: {$0}){viewStore in
            GeometryReader{outerProxy in
                HStack{
                    Path{
                        $0.move(to: CGPoint(x: outerProxy.size.width - 30, y: 0))
                        $0.addLine(to: CGPoint(x: outerProxy.size.width - 30, y: outerProxy.size.height - 12))
                        $0.addLine(to: CGPoint(x: 0, y: outerProxy.size.height - 12))
                    }.stroke(Color.gray)
                        .frame(width: outerProxy.size.width - 30, height: outerProxy.size.height - 12)
                        .overlay{
                            GeometryReader{proxy in
                                ScrollViewReader{scrollReader in
                                    ScrollView(.horizontal,showsIndicators: false){
                                        HStack{
                                            Spacer()
                                            
                                            ForEach(0 ..< viewStore.datas.count, id: \.self){index in
                                                MetricChartItemView(item: viewStore.datas[index], baseRange: viewStore.baseRange, baseHeight: Float(outerProxy.size.height) - 12)
                                                    .opacity(index == viewStore.selected ? 1 : 0.3)
                                                    .onTapGesture{
                                                        viewStore.send(.selectItem(index))
                                                    }
                                            }
                                            
                                            Spacer().frame(width:20)
                                                .id(viewStore.datas.count)
                                        }.frame(width:proxy.size.width,height:proxy.size.height + 21)
                                    }
                                    .onAppear{
                                        scrollReader.scrollTo(viewStore.datas.count)
                                    }
                                }
                            }
                        }
                    
                    
                    VStack{
                        Text(numberFormatter.string(for: viewStore.baseRange.max)!)
                            .font(.notoSans(size: 12))
                        Spacer()
                        Text(numberFormatter.string(for: viewStore.baseRange.min)!)
                            .font(.notoSans(size: 12))
                    }.frame(height:outerProxy.size.height)
                }
                .frame(height: outerProxy.size.height)
                .onChange(of: viewStore.period){_ in
                    viewStore.send(.selectItem(nil))
                    viewStore.send(.fetchMetricDatas(metric, .now))
                }
                .onAppear{
                    viewStore.send(.fetchMetricDatas(metric, .now))
                }
            }
        }
        
        
    }
    
    
    private let metric: Metric
    private let store: StoreOf<MetricChart>
    private let numberFormatter: NumberFormatter
}

struct MetricChartItemView: View{
    init(item: MetricData<MinMaxType<Float>>, baseRange: MinMaxType<Float>, baseHeight: Float) {
        self.baseRange = baseRange
        self.item =  item
        self.ratio = (baseRange.max - baseRange.min) / baseHeight
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
    }
    
    var body: some View{
        VStack(spacing:0){
            let upper = baseRange.max - item.value.max
            
            if upper != 0{
                Spacer()
                    .frame(height: CGFloat(upper / ratio))
                
            }
            Capsule()
                .frame(maxWidth: 5, minHeight:3)
            
            let lower = item.value.min - baseRange.min
            
            if lower != 0 && item.value.min != item.value.max{
                Spacer()
                    .frame(height:CGFloat(lower / ratio))
            }
            else if item.value.max == item.value.min{
                let h = (1 / ratio) * (baseRange.max - baseRange.min)
                Spacer()
                    .frame(height: max(CGFloat(h) - CGFloat(upper / ratio) - 4, 0))
            }
            Text(dateFormatter.string(from: item.basisDate))
                .font(.notoSans(size: 14))
                .foregroundColor(.gray).padding(.top, 3)
        }.font(.notoSans(size: 14,weight: .bold)).foregroundColor(.blue)
    }
    private let dateFormatter: DateFormatter
    private let ratio: Float
    private let item: MetricData<MinMaxType<Float>>
    private let baseRange: MinMaxType<Float>
}
