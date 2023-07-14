//
//  ChangePasswordView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/15.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct ChangePasswordView:View{
    init(store: StoreOf<ChangePassword>){
        self.store = store
    }
    var body: some View {
        WithViewStore(store, observe: {$0}){viewStore in
            VStack(alignment: .leading, spacing:30){

                VitalWinkFormSection(header: "새 비밀번호",errorMessage: "비밀번호는 6~18자 사이의 문자이어야 합니다.", shouldShowErrorMessage: !viewStore.password.isEmpty && !viewStore.isPasswordValid){
                    SecureField("새 비밀번호", text: viewStore.binding(\.$password))
                        .textContentType(.newPassword)
                        .textFieldStyle(VitalWinkTextFieldStyle())
                }
                VitalWinkFormSection(header: "새 비밀번호 확인",errorMessage: "비밀번호 확인이 비밀번호와 일치하지 않습니다.", shouldShowErrorMessage:
                                        (viewStore.password.isEmpty && !viewStore.repeatPassword.isEmpty) || (!viewStore.password.isEmpty &&  !viewStore.isRepeatPasswordValid)){
                    SecureField("새 비밀번호 확인", text: viewStore.binding(\.$repeatPassword))
                        .textContentType(.newPassword)
                        .textFieldStyle(VitalWinkTextFieldStyle())
                }
                
                Spacer()
                
                Button("비밀번호 변경"){
                    viewStore.send(.changePassword)
                }.buttonStyle(VitalWinkButtonStyle(isDisabled: isChangePasswordButtonDiabled))
                .disabled(isChangePasswordButtonDiabled)
            }
            
            .padding(.top, 25)
            .padding(.horizontal, 20)
            .background(Color.backgroundColor)
            .navigationTitle(Text("비밀번호 변경"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Image(systemName: "chevron.backward")
                        .font(.system(size:15))
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
            .vitalWinkAlert(store.scope(state: \.alertState, action: {$0}), dismiss: .alertDismiss)
            .activityIndicator(isVisible: viewStore.isActivityIndicatorVisible)
            .onChange(of: viewStore.shouldViewDismiss){
                if $0{
                    dismiss()
                }
            }
            .onChange(of: viewStore.password.isEmpty || !viewStore.isPasswordValid || viewStore.repeatPassword.isEmpty || !viewStore.isRepeatPasswordValid){
                isChangePasswordButtonDiabled = $0
            }
//                    .onDisappear{
//                viewStore.send(.onDisappear)
//            }
        }
    }
    
    @State private var isChangePasswordButtonDiabled = true
    private let store: StoreOf<ChangePassword>
    @Environment(\.dismiss) private var dismiss
}
