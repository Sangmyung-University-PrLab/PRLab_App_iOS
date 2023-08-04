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
        ZStack(alignment:.bottomTrailing){
            ZStack(alignment: .top){
                Color
                    .black
                    .opacity(0.3)
                if index > 1{
                    Circle()
                        .frame(width: 40, height: 40)
                        .blendMode(.destinationOut)
                        .position(x:highlightXPosition, y: 23 + (UIApplication.shared.safeAreaInsets?.top ?? 0))
                }
               
            }
            .ignoresSafeArea()
            .compositingGroup()
           
            VStack(spacing:25){
                GIFView(url: Bundle.main.url(forResource: target == .face ? "face_help" : "finger_help", withExtension: ".gif")!)
                Text(message[index])
                    .multilineTextAlignment(.center)
                    .font(.notoSans(size: 14, weight: .bold))
                    .padding(.bottom, 25)
            }
            .background{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
            
            
            
            Button(index < message.count - 1 ? "다음" :  "닫기"){
                if index < message.count - 1{
                    index += 1
                }
                else{
                    let helpKey = target == .face ? UserDefaultsKey.isShowedFaceHelp : UserDefaultsKey.isShowedFingerHelp
                    UserDefaults.standard.setValue(true, forKey: helpKey.rawValue)
                }
            }.buttonStyle(VitalWinkButtonStyle())
            .frame(width:60, height:20)
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }.onChange(of: index){
            if $0 == 2{
                highlightXPosition = 26
            }
            else if $0 == 3{
                highlightXPosition = (UIApplication.shared.barManager?.statusBarFrame.width ?? 0) / 2
            }
            else if $0 == 4{
                highlightXPosition = (UIApplication.shared.barManager?.statusBarFrame.width ?? 0) - 30
            }
        }
    }
    
    
    /*
     26, UIApplication.shared.barManager?.statusBarFrame.width ?? 0) / 2
     */
    @State private var highlightXPosition: CGFloat = 0
    @State private var index: Int = 0
    private var message: [String]{
        switch target{
        case .face:
            return ["안정적인 측정을 위해서\n핸드폰을 거치대 등으로 고정시켜주세요.",
                    "측정 버튼을 누르면\n15초간 생체신호를 측정합니다.",
                    "* 좌상단의 아이콘을 눌러\n기록된 정보를 확인할 수 있습니다.",
                    "* 상단의 중앙 아이콘을 눌러\n카메라 렌즈를 변경할 수 있습니다.",
                    "* 우상단의 아이콘을 눌러\n로그아웃 및 회훤탈퇴를 할 수 있습니다."]
        case .finger:
            return [ "후면의 플래시가 켜집니다.\n통증이 느껴진다면 즉시 측정을 중단하세요.",
                     "측정 버튼을 누르면\n15초간 생체신호를 측정합니다."]
        }
    }
    private let target: Measurement.Target
}

struct MeasurementHelpView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementHelpView(target: .face)
    }
}
