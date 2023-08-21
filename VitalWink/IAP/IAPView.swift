//
//  IAPView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/08/17.
//

import SwiftUI
import StoreKit
import ComposableArchitecture
struct IAPView: View {
    init(store: StoreOf<IAP>){
        self.store = store
    }
    var body: some View {
        WithViewStore(store, observe: {$0}){viewStore in
            VStack(alignment: .leading, spacing: 20){
                HStack{
                    Spacer()
                    
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150)
                    Spacer()
                }.padding(.bottom, 50)
                    .padding(.top, 50)
                
                descriptionView(descirption: "얼굴 혹은 손가락 영상으로 바이오 마커를 간편하게 측정하세요.")
                descriptionView(descirption: "측정된 기록을 주/달/년 단위로 조회할 수 있습니다.")
                descriptionView(descirption:"첫 달 무료로 앱의 기능을 체험해보세요.")
                descriptionView(descirption: "첫 달 무료 이후 **월 2900원**으로 앱의 모든 기능을 사용하실 수 있습니다.")
                
                Button("구독하기"){
                    viewStore.send(.subscribe)
                }.buttonStyle(VitalWinkButtonStyle())
                
                Group{
                    Text("결제는 App Store 계정의 정보로 결제가 진행되며, 구독 종료 24시간 전에 취소하지 않으면 자동으로 갱신됩니다. 구독은 사용자의 계정 설정에서 관리할 수 있습니다.")
                    
                    Link(destination:  URL(string: "https://github.com/Sangmyung-University-PrLab/PRLab_App_iOS/blob/release/VitalWink/개인정보 처리방침.pdf".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")!){
                        Text("개인정보 처리방침")
                            .underline()
                    }
                        .buttonStyle(.plain)
                }
                .font(.notoSans(size: 12, weight: .light))
                .foregroundColor(.gray)
                
                Spacer()
            }
            .font(.notoSans(size: 16,weight: .medium))
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight:.infinity)
            .background{
                Color.backgroundColor.ignoresSafeArea()
            }
            .navigationBarBackButtonHidden()
            .toolbar{
                VitalWinkBackButton()
            }
            .onAppear{
                viewStore.send(.getProducts)
            }
        }
    }
    
    @State private var shouldShowManageSubscriptionSheet = false
    private let store: StoreOf<IAP>
    
    @ViewBuilder
    private func descriptionView(descirption: String) -> some View{
        HStack(alignment:.top){
            Image(systemName: "checkmark.circle.fill")
                .renderingMode(.template)
                .foregroundColor(.blue)

            Text(LocalizedStringKey(descirption))
        }
    }
}

struct IAPView_Previews: PreviewProvider {
    static var previews: some View {
        IAPView(store: Store(initialState: IAP.State(), reducer: IAP()))
    }
}
