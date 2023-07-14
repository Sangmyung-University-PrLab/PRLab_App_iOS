//
//  FindPasswordView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/14.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct FindPasswordView: View{
    init(store: StoreOf<User>){
        self.store = store.scope(state: \.findUserInfo, action: User.Action.findUserInfo)
    }
    var body: some View {
        WithViewStore(store, observe: {$0}){viewStore in
            VStack(alignment: .leading, spacing:30){

                VitalWinkFormSection(header: "아이디",errorMessage: "아이디에 맞지 않는 형식입니다.", shouldShowErrorMessage: !viewStore.id.isEmpty && !viewStore.isIdValid){
                    TextField("아이디", text: viewStore.binding(\.$id))
                        .textFieldStyle(VitalWinkTextFieldStyle())
                }
                
                VitalWinkFormSection(header: "이메일",errorMessage: "이메일에 맞지 않는 형식입니다.", shouldShowErrorMessage: !viewStore.email.isEmpty && !viewStore.isEmailValid){
                    TextField(text: viewStore.binding(\.$email)){
                        Text(verbatim: "email@email.com")
                    }  .textFieldStyle(VitalWinkTextFieldStyle())
                }
                
                Spacer()
                
                Button("비밀번호 찾기"){
                    viewStore.send(.isIdAndEmailMatch)
                }.buttonStyle(VitalWinkButtonStyle(isDisabled: isFindPasswordButtonDisabled))
                .disabled(isFindPasswordButtonDisabled)
                
                IfLetStore(self.store.scope(state: \.changePassword, action: FindUserInfo.Action.changePassword)){
                    store in
                    NavigationLink(isActive: viewStore.binding(\.$shouldShowChangePasswordView)){
                        ChangePasswordView(store: store)
                        .onDisappear{
                            viewStore.send(FindUserInfo.Action.changePasswordViewDismissed)
                        }
                    }label:{
                        
                    }
                }.hidden()
            }
            .padding(.top, 25)
            .padding(.horizontal, 20)
            .background(Color.backgroundColor.ignoresSafeArea() .onTapGesture {
                hideKeyboard()
            })
            .navigationTitle(Text("비밀번호 찾기"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)

            .toolbar{
                VitalWinkBackButton()
            }
            .vitalWinkAlert(store.scope(state: \.alertState, action: {$0}), dismiss: .alertDismiss)
            .activityIndicator(isVisible: viewStore.isActivityIndicatorVisible)
            .onChange(of: viewStore.shouldViewDismiss){
                if $0{
                    dismiss()
                }
            }.onChange(of: viewStore.email.isEmpty || !viewStore.isEmailValid || viewStore.id.isEmpty || !viewStore.isIdValid){
                isFindPasswordButtonDisabled = $0
            }.onDisappear{
                viewStore.send(.onDisappear)
            }
        }
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var isFindPasswordButtonDisabled = true
    private let store: StoreOf<FindUserInfo>
}
