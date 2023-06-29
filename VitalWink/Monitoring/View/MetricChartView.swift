//
//  MetricCharView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/29.
//

import Foundation
import Charts
import SwiftUI

struct MetricChartView: View{
    init(data: [MinMaxType<Float>]){
        self.data = data.reversed()
        
        self.baseRange = data.reduce(MinMaxType(min: 0.0, max: 0.0)){
            let min = $0.min < $1.min ? $0.min : $1.min
            let max = $0.max > $1.max ? $0.max : $1.max
            
            return MinMaxType(min: min, max: max)
        }
    }
    
    var body: some View{
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
                                        ForEach(0 ..< data.count, id: \.self){
                                            MetricChartItemView(item: data[$0], baseRange: MinMaxType(min: 61, max: 138), baseHeight: Float(outerProxy.size.height) - 12)
                                        }
                                        
                                        Spacer().frame(width:20)
                                            .id(data.count)
                                    }
                                } .frame(height: outerProxy.size.height - 12)
                                    .onAppear{
                                        scrollReader.scrollTo(data.count)
                                    }
                            }
                            
                        }
                    }
                
                VStack{
                    Text("138")
                        .font(.notoSans(size: 12))
                    Spacer()
                    Text("61")
                        .font(.notoSans(size: 12))
                }.frame(height:outerProxy.size.height)
            }.frame(height: outerProxy.size.height)
        }
    }

    
    private let baseRange: MinMaxType<Float>
    private let data: [MinMaxType<Float>]
}

struct MetricChartItemView: View{
    init(item: MinMaxType<Float>, baseRange: MinMaxType<Float>, baseHeight: Float) {
        self.baseRange = baseRange
        self.item =  item.min == baseRange.min ? MinMaxType(min: item.min, max: item.max): item
        self.ratio = (baseRange.max - baseRange.min) / baseHeight
    }
    
    var body: some View{
        VStack(spacing:5){
            Spacer()
                .frame(height: CGFloat((baseRange.max - item.max) / ratio))
     
            Capsule()
                .frame(maxWidth: 5, minHeight:1)
      
            Spacer().frame(height:CGFloat((item.min - baseRange.min) / ratio))
        }.font(.notoSans(size: 14,weight: .bold)).foregroundColor(.blue)
    }
    
    private let ratio: Float
    private let item: MinMaxType<Float>
    private let baseRange: MinMaxType<Float>
}

struct MetricCharView_Previews: PreviewProvider{
    static var previews: some View{
        
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
        
        MetricChartView(data:demoData).frame(width:312)
    }
}



