//
//  PiChartView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/10.
//

import Foundation
import SwiftUI
import ComposableArchitecture
struct PieChartView: View{
    init(expressions: [Expression: Float], numberFormatter: NumberFormatter? = nil){
        if numberFormatter == nil{
            self.formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
        }
        else{
            formatter = numberFormatter!
        }
        self.expressions = expressions
    }

    var body: some View{
        GeometryReader{proxy in
            VStack(spacing:20){
                Canvas{context, size in
                    var startAngle = Angle.zero
                    var textPoint = CGPoint.zero
                    
                    let origin = CGPoint(x: size.width / 2, y: size.height / 2)
                    for (key, value) in self.expressions{
                        let delta = Angle(degrees: Double(value * 360))
                        let endAngle = startAngle + delta
                        let halfAngle = startAngle + delta / 2
                        
                        textPoint = value == 1 ? origin : CGPoint(x: size.width / 4 * CGFloat(cos(halfAngle.radians)) + origin.x, y: size.width / 4 * sin(halfAngle.radians) + origin.y)
                        
                        let path = Path{
                            $0.move(to: CGPoint(x: size.width / 2, y: size.height / 2))
                            $0.addArc(center: CGPoint(x: size.width / 2, y: size.height / 2), radius: size.width / 2 - 30, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                            $0.closeSubpath()
                        }
                        context.fill(path, with: .color(key.color))
                        if value != 0{
                            context.draw(Text(formatter.string(for:value) ?? "").font(.notoSans(size: 11, weight: .medium)), at: textPoint)
                        }
                        
                        startAngle = endAngle
                    }
                }
                .aspectRatio(contentMode: .fit)
//                .frame(height: proxy.size.width)
                    

                let expressions = Expression.allCases
                let subExpressions1 = expressions[0 ..< expressions.index(expressions.startIndex, offsetBy: 4)]
                let subExpressions2 = expressions[ expressions.index(expressions.startIndex, offsetBy: 4) ..< expressions.endIndex]
                
                HStack(spacing:0){
                    ForEach(0 ..< subExpressions1.count, id: \.self){
                        let index = subExpressions1.index(subExpressions1.startIndex, offsetBy: $0)
                        let expression = subExpressions1[index]
                        PieChartLegendItemView(label: expression.korean)
                            .foregroundColor(expression.color)
                        
                    }
                }
                HStack(spacing:0){
                    ForEach(0 ..< subExpressions2.count, id: \.self){
                        let index = subExpressions2.index(subExpressions2.startIndex, offsetBy: $0)
                        let expression = subExpressions2[index]
                        PieChartLegendItemView(label: expression.korean)
                            .foregroundColor(expression.color)
                    }
                }
                
            }
            .position(CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2))
        }
    }
    
    private let expressions:  [Expression: Float]
    private let formatter: NumberFormatter
}

struct PieChartLegendItemView: View{
    init(label: String){
        self.label = label
    }
    var body: some View{
        HStack(spacing: 0){
            Spacer()
            Circle()
                .frame(width: 12, height: 12)
            Spacer()
            Text(label)
                .font(.notoSans(size: 11, weight: .medium))
                .foregroundColor(.black)
            Spacer()
        }
    }
    private let label: String
}

//struct PiChartView_Previews: PreviewProvider{
//    static var previews: some View{
//        PieChartView()
//    }
//}
