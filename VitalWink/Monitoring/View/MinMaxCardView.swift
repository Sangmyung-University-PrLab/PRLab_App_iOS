//
//  MinMaxCardView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/03.
//

import Foundation
import SwiftUI

struct MinMaxCardView: View{
    init(data: MinMaxType<Float>, metric: Metric,formatter: NumberFormatter){
        self.data = data
        self.metric = metric
        self.formatter = formatter
    }
    
    
    var body: some View{
        RoundedRectangle(cornerRadius: 8)
            .foregroundColor(.white)
            .frame(height: 90).overlay{
                VStack(spacing:0){
                    HStack(spacing:0){
                        Text("최소")
                            .font(.notoSans(size: 12,weight: .medium))
                            .padding(.trailing, 10)
                            .foregroundColor(.gray)
                            
                        Text("\(formatter.string(for: data.min) ?? "")")
                            .font(.notoSans(size: 20,weight: .bold))
                            .padding(.trailing, 5)
                        Text(metric.unit ?? "")
                            .font(.notoSans(size: 12,weight: .medium))
                        Spacer()
                        Text("-").font(.notoSans(size: 12,weight: .medium)).foregroundColor(.gray)
                        Spacer()
                        Text("최대").font(.notoSans(size: 12,weight: .medium))
                            .padding(.trailing, 10).foregroundColor(.gray)
                        Text("**\(formatter.string(for: data.max) ?? "")**")
                            .font(.notoSans(size: 20,weight: .bold))
                            .padding(.trailing, 5)
                        Text(metric.unit ?? "")
                            .font(.notoSans(size: 12,weight: .medium))
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 10)
                    
                        GeometryReader{proxy in
                            let inndexCapsuleWidth = proxy.size.width * CGFloat(Float(data.max - data.min) / (metric.max - metric.min))
                                Capsule()
                                    .foregroundColor(.blue.opacity(0.3))
                                    .frame(height: 5)
                                    .padding(.horizontal, 10)
                                    .overlay(alignment:.leading){
                                        Capsule()
                                            .foregroundColor(.blue)
                                            .frame(width: inndexCapsuleWidth)
                                            .offset(x: getOffset(width: proxy.size.width))
                                        
                                    }

                        }.frame(height: 5)
                        .padding(.bottom, 5)
                    
                    HStack(spacing:0){
                        Text("\(formatter.string(for: metric.min) ?? "")")
                        Spacer()
                        Text("\(formatter.string(for: metric.max) ?? "")")
                    }
                    .font(.notoSans(size: 12,weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                    Spacer()
                }
            }
    }
    
    private func getOffset(width: CGFloat) -> CGFloat{
        return CGFloat((Float(data.min) - metric.min) / (metric.max - metric.min)) * width
    }
    
    private let data: MinMaxType<Float>
    private let formatter: NumberFormatter
    private let metric: Metric
}

