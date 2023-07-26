//
//  ReferenceView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/26.
//

import SwiftUI

struct ReferenceView: View {
    var body: some View {
        List{
            makeColumn(metric: "심박수", linkTitle: "Restoration of Remote PPG Signal through Correspondence with Contact Sensor Signal",url: URL(string: "https://www.mdpi.com/1424-8220/21/17/5910")!)
                .padding(.vertical, 10)
            makeColumn(metric: "산소포화도", linkTitle: "Non-Contact Oxygen Saturation Measurement Using YCgCr Color Space with an RGB Camera",url: URL(string: "https://www.mdpi.com/1424-8220/21/18/6120")!)
            makeColumn(metric: "분당 호흡수", linkTitle: "Algorithms for Monitoring Heart Rate and Respiratory Rate From the Video of a User’s Face",url: URL(string: "https://ieeexplore.ieee.org/abstract/document/8337005")!)
            makeColumn(metric: "표정분석", linkTitle: "Fast and Accurate Facial Expression Image Classification and Regression Method Based on Knowledge Distillation",url: URL(string: "https://www.mdpi.com/2076-3417/13/11/6409")!)
                
            makeColumn(metric: "혈압", linkTitle: "Assessment of Non-Invasive Blood Pressure Prediction from PPG and rPPG Signals Using Deep Learning",url: URL(string: "https://www.mdpi.com/1424-8220/21/18/6022")!)
            makeColumn(metric: "BMI", linkTitle: "Multi-View Body Image-Based Prediction of Body Mass Index and Various Body Part Sizes.",url: URL(string: "https://openaccess.thecvf.com/content/CVPR2023W/CVPM/html/Kim_Multi-View_Body_Image-Based_Prediction_of_Body_Mass_Index_and_Various_CVPRW_2023_paper.html")!)
        }
        .navigationTitle("기술출처")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar{
            VitalWinkBackButton()
        }
    }
    
    @ViewBuilder
    func makeColumn(metric: String, linkTitle: String, url: URL) -> some View{
        GeometryReader{proxy in
            HStack{
                Text(metric).font(.notoSans(size: 14, weight: .bold))
                    .frame(width: proxy.size.width * 0.3)
            
                Link(linkTitle, destination: url)
                    .font(.notoSans(size: 12))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: proxy.size.width * 0.7, alignment: .leading)
            }
            .position(x: proxy.size.width / 2 , y: proxy.size.height / 2)
        }.padding(.vertical, 20)
        
        
    }
}

struct ReferenceView_Previews: PreviewProvider {
    static var previews: some View {
        ReferenceView()
    }
}
