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
                GeometryReader{proxy in
                    HStack(spacing:10){
                        ScrollViewReader{scrollReader in
                            ScrollView(.horizontal,showsIndicators: false){
                                LazyHStack(spacing: 10){
                                    ForEach(viewStore.sortedKeys, id: \.self){key in
                                        let yyyyMMdd = key.split(separator: "/").map{Int($0)!}
                                        let x = yyyyMMdd[2] == 1 ? "\(yyyyMMdd[1])/\(yyyyMMdd[2])" : "\(yyyyMMdd[2])"
                                        
                                        MetricChartItemView(x:x,y: viewStore.datas[key, default: nil]?.value, baseRange: viewStore.baseRange, baseHeight: Float(proxy.size.height) - 30)
                                            .frame(width: (proxy.size.width - 50 - 10 * 6) / 7)
                                            .onAppear{
                                                Task{
                                                    viewStore.send(.changeVisible(key,true))
                                                    guard let first = viewStore.sortedKeys.first else{
                                                        return
                                                    }

                                                    if first == key{
                                                        viewStore.send(.refresh(metric))
                                                    }
                                                }
                                               
                                            }.onDisappear{
                                                Task{
                                                    viewStore.send(.changeVisible(key,false))
                                                }
                                                
                                            }
                                            .onTapGesture{
                                                viewStore.send(.selectItem(key))
                                            }
                                            .foregroundColor(.blue)
                                            .opacity(viewStore.selected == key ? 1 : 0.3)
                                    }
                                }
                            
                                .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                                
                            }
                            .frame(width: proxy.size.width - 30)
                            .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                            
                        }
                        .overlay{
                            Path{
                                $0.move(to: CGPoint(x:0, y:proxy.size.height - 30))
                                $0.addLine(to: CGPoint(x:proxy.size.width - 30, y: proxy.size.height - 30))
                                $0.addLine(to: CGPoint(x:proxy.size.width - 30, y: 0))
                            }.stroke(Color.gray)
                            
                        }
                        
                        VStack(spacing: 0){
                            if let baseRange = viewStore.baseRange{
                                Text(numberFormatter.string(for: baseRange.max)!)
                                Spacer()
                                Text(numberFormatter.string(for: baseRange.min)!)
                            }
                            Spacer().frame(height:30)
                        }.font(.notoSans(size: 12, weight: .medium))
                        .frame(height:proxy.size.height + 12)
                    }
                 
                }
             
                .onChange(of: viewStore.period){_ in
                    viewStore.send(.selectItem(nil))
                    viewStore.send(.fetchMetricDatas(metric, .now))
                }
                .onAppear{
                    viewStore.send(.fetchMetricDatas(metric, .now))
                }
            }
        
        
        
    }

    private let metric: Metric
    private let store: StoreOf<MetricChart>
    private let numberFormatter: NumberFormatter
    
}

struct MetricChartItemView: View{
    init(x:String, y: MinMaxType<Float>? = nil, baseRange: MinMaxType<Float>?, baseHeight: Float) {
        self.baseRange = baseRange
        self.x = x
        self.y = y
        if let baseRange = baseRange{
            self.ratio = (baseRange.max - baseRange.min) / baseHeight
        }
        else{
            self.ratio = 1
        }
        
        self.baseHeight = CGFloat(baseHeight)
    }
    
    var body: some View{
        VStack(spacing:0){
            if let value = y {
                if let baseRange = self.baseRange{
                    let upper = max(baseRange.max - value.max, 0)
                    
                    if upper != 0{
                        Spacer()
                            .frame(height: CGFloat(upper / ratio))
                        
                    }
                    Capsule()
                        .frame(maxWidth: 5, minHeight:3)
                    
                    let lower = max(value.min - baseRange.min,0)
                    
                    if lower != 0 && value.min != value.max{
                        Spacer()
                            .frame(height:CGFloat(lower / ratio))
                    }
                    else if value.max == value.min && value != baseRange{
                        
                        Spacer()
                            .frame(height: max(baseHeight - CGFloat(upper / ratio) - 4, 0))
                    }
                }else{
                    Capsule()
                        .frame(maxWidth: 5, minHeight:3)
                }
            }
            else{
                Spacer()
                    .frame(height: baseHeight)
            }
            Text(x)
                .font(.notoSans(size: 12))
                .foregroundColor(.gray)
                .padding(.top, 10)
                .frame(height:30)
        }
    }

    private let ratio: Float
    private let x: String
    private let y: MinMaxType<Float>?
    private let baseRange: MinMaxType<Float>?
    private let baseHeight: CGFloat
}


struct MetricChart_Previews: PreviewProvider{
    static var previews: some View{
        MetricChartView(store: Store(initialState: MetricChart.State(), reducer: MetricChart()), metric: .bpm)
        
        
//        let viewStore = Store(initialState: MetricChart.State(), reducer: MetricChart())
//        GeometryReader{proxy in
//            ScrollViewReader{scrollReader in
//                ScrollView(.horizontal,showsIndicators: false){
//                    HStack(spacing: 10){
//
//                        ForEach(0 ..< 14, id: \.self){index in
//                            Rectangle()
//                                .frame(width:proxy.size.width / 7)
//                                .id(index)
//                        }
//
//
//                    }
//                }
//                .onAppear{
//                    scrollReader.scrollTo(13)
//                }
//            }
//        }.padding(.horizontal, 20)
    }
}
