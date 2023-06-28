//
//  MetricCardView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/28.
//

import SwiftUI

struct MetricCardView: View {
    init(metric: String, value: String, icon: Image, unit: String? = nil){
        self.metric = metric
        self.value = value
        self.icon = icon
        self.unit = unit
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .foregroundColor(.white)
            .frame(width:280, height: 100)
            .overlay{
                VStack(spacing:10){
                    HStack(spacing:0){
                        Text(metric)
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
    }
    
    private let metric: String
    private let value: String
    private let icon: Image
    private let unit: String?
}

struct MetricCardView_Previews: PreviewProvider {
    static var previews: some View {
        MetricCardView(metric: "심박수", value: "\(76)", icon: Image("bpm_icon"), unit: "bpm")
    }
}
