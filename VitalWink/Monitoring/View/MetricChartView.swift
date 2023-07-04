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
                                        LazyHStack(spacing: 10){
                                            ForEach(keys, id: \.self){key in
                                                let yyyyMMdd = key.split(separator: "/").map{Int($0)!}
                                                let x = yyyyMMdd[2] == 1 ? "\(yyyyMMdd[1])/\(yyyyMMdd[2])" : "\(yyyyMMdd[2])"
                                                
                                                MetricChartItemView(x:x,y: viewStore.datas[key, default:nil], baseRange: viewStore.baseRange, baseHeight: Float(outerProxy.size.height) - 12)
                                                    .frame(width: (proxy.size.width - 10 * 6) / 7)
                                                    .onAppear{
                                                        guard let first = keys.first else{
                                                            return
                                                        }
                                                        
                                                        if first == key{
                                                            viewStore.send(.refresh(metric))
                                                        }
                                                    }
                                            }
                                        }.scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                                      
                                    }.scaleEffect(x: -1.0, y: 1.0, anchor: .center)

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
                .onChange(of:viewStore.datas){
                    keys = $0.keys.sorted()
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
        
        
    }
    @State var keys:[String] = []
    private let metric: Metric
    private let store: StoreOf<MetricChart>
    private let numberFormatter: NumberFormatter
    
}

struct MetricChartItemView: View{
    init(x:String, y: MinMaxType<Float>? = nil, baseRange: MinMaxType<Float>, baseHeight: Float) {
        self.baseRange = baseRange
        self.x = x
        self.y = y
        self.ratio = (baseRange.max - baseRange.min) / baseHeight
        
        self.baseHeight = CGFloat(baseHeight)
    }
    
    var body: some View{
        VStack(spacing:0){
            if let value = y {
                let upper = baseRange.max - value.max
                
                if upper != 0{
                    Spacer()
                        .frame(height: CGFloat(upper / ratio))
                    
                }
                Capsule()
                    .frame(maxWidth: 5, minHeight:3)
                
                let lower = value.min - baseRange.min
                
                if lower != 0 && value.min != value.max{
                    Spacer()
                        .frame(height:CGFloat(lower / ratio))
                }
                else if value.max == value.min{
                   
                    Spacer()
                        .frame(height: max(baseHeight - CGFloat(upper / ratio) - 4, 0))
                }
            }
            else{
                Spacer()
                    .frame(height: baseHeight)
            }
            Text(x)
                .font(.notoSans(size: 12))
                .foregroundColor(.gray).padding(.top, 3)
        }
    }

    private let ratio: Float
    private let x: String
    private let y: MinMaxType<Float>?
    private let baseRange: MinMaxType<Float>
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
