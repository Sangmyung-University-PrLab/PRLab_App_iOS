//
//  FindIdView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/13.
//

import SwiftUI
import ComposableArchitecture

struct FindIdView: View {
    init(store: StoreOf<User>){
        self.store = store.scope(state: \.findUserInfo, action: User.Action.findUserInfo)
    }
    var body: some View {
        WithViewStore(store, observe: {$0}){viewStore in
            VStack(alignment: .leading, spacing:30){
                VitalWinkFormSection(header: "이메일",errorMessage: "이메일에 맞지 않는 형식입니다.", shouldShowErrorMessage: !viewStore.email.isEmpty && !viewStore.isEmailValid){
                    TextField(text: viewStore.binding(\.$email)){
                        Text(verbatim: "email@email.com")
                    }  .textFieldStyle(VitalWinkTextFieldStyle())
                }
                
                Spacer()
                
                Button("아이디 찾기"){
                    viewStore.send(.findId)
                }.buttonStyle(VitalWinkButtonStyle(isDisabled: isFindIdButtonDisabled))
                .disabled(isFindIdButtonDisabled)
            }
            
            .padding(.top, 25)
            .padding(.horizontal, 20)
            .background(Color.backgroundColor.onTapGesture {
                hideKeyboard()
            })
            .navigationTitle(Text("아이디 찾기"))
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
            }.onChange(of: viewStore.email.isEmpty || !viewStore.isEmailValid){
                isFindIdButtonDisabled = $0
            }.onDisappear{
                viewStore.send(.onDisappear)
            }
        }
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var isFindIdButtonDisabled = true
    private let store: StoreOf<FindUserInfo>
}

//struct FindIdView_Previews: PreviewProvider {
//    static var previews: some View {
//        FindIdView(store: Store(initialState: Root.State().user, reducer: User()))
//    }
//}
