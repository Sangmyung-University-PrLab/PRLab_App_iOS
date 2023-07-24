//
//  MeasurementHelpView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/14.
//

import SwiftUI

struct MeasurementHelpView: View {
    init(target: Measurement.Target){
        self.target = target
    }
    var body: some View {
        ZStack{
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing:25){
                GIFView(url: Bundle.main.url(forResource: target == .face ? "face_help" : "finger_help", withExtension: ".gif")!)
                Text(message)
                    .multilineTextAlignment(.center)
                    .font(.notoSans(size: 14, weight: .bold))
                    .padding(.bottom, 25)
            }
            
            .background{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 60)
            .padding(.vertical, 150)
        }.onTapGesture {
            let helpKey = target == .face ? UserDefaultsKey.isShowedFaceHelp : UserDefaultsKey.isShowedFingerHelp
            UserDefaults.standard.setValue(true, forKey: helpKey.rawValue)
        }
        
    }
    
    private var message: String{
        switch target{
        case .face:
            return "얼굴을 이용하여 생체 신호를 측정합니다.\n 움직임을 최소화 해주세요."
        case .finger:
            return "손가락을 이용하여 생체 신호를 측정합니다.\n 후면 카메라에 손가락을 밀착해주세요."
        }
    }
    private let target: Measurement.Target
}

struct MeasurementHelpView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementHelpView(target: .finger)
    }
}
