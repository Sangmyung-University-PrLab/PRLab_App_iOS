//
//  SignUpView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/11.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct SignUpView: View{
    init(store: StoreOf<User>){
        self.store = store.scope(state: \.signUp, action: User.Action.signUp)
    }
    var body: some View{
        WithViewStore(store, observe: \.property){viewStore in
            ScrollView(.vertical, showsIndicators: false){
                VStack(alignment: .leading, spacing:30){
                    VitalWinkFormSection(header: "아이디",errorMessage: "아이디에 맞지 않는 형식입니다.", shouldShowErrorMessage: !viewStore.id.isEmpty && !viewStore.isIdValid){
                        HStack{
                            TextField("아이디", text: viewStore.binding(get:\.id, send: SignUp.Action.idChanged))
                                .textFieldStyle(VitalWinkTextFieldStyle())
                            
                            Button("중복검사"){
                                viewStore.send(.checkIdDuplicated)
                            }
                            .frame(width:75)
                            .buttonStyle(VitalWinkButtonStyle(isDisabled: viewStore.id.isEmpty || !viewStore.isIdValid))
                            .disabled(viewStore.id.isEmpty || !viewStore.isIdValid)
                        }
                    }
                    VitalWinkFormSection(header: "비밀번호",errorMessage: "비밀번호는 6~18자 사이의 문자이어야 합니다.", shouldShowErrorMessage: !viewStore.password.isEmpty && !viewStore.isPasswordValid){
                        SecureField("비밀번호", text: viewStore.binding(get:\.password, send: SignUp.Action.passwordChanged))
                            .textContentType(.newPassword)
                            .textFieldStyle(VitalWinkTextFieldStyle())
                    }
                    VitalWinkFormSection(header: "비밀번호 확인",errorMessage: "비밀번호 확인이 비밀번호와 일치하지 않습니다.", shouldShowErrorMessage:
                        (viewStore.password.isEmpty && !viewStore.repeatPassword.isEmpty) || (!viewStore.password.isEmpty &&  !viewStore.isRepeatPasswordValid)){
                        SecureField("비밀번호 확인", text: viewStore.binding(get:\.repeatPassword, send: SignUp.Action.repeatPasswordChanged))
                            .textContentType(.newPassword)
                            .textFieldStyle(VitalWinkTextFieldStyle())
                    }
                    
                    VitalWinkFormSection(header: "이메일",errorMessage: "이메일에 맞지 않는 형식입니다.", shouldShowErrorMessage: !viewStore.email.isEmpty && !viewStore.isEmailValid){
                        TextField(text: viewStore.binding(get:\.email, send: SignUp.Action.emailChanged)){
                            Text(verbatim: "email@email.com")
                        }
                        .textFieldStyle(VitalWinkTextFieldStyle(isDisabled: !viewStore.isEmailTexFieldDisabled))
                    }
                    
                    VitalWinkFormSection(header: "성별"){
                        CircularSegmentedPickerView(selected: viewStore.binding(get:\.gender, send: SignUp.Action.genderChanged), texts: ["남성", "여성"])
                    }
                    VitalWinkFormSection(header: "생년월일"){
                        DatePicker("", selection: viewStore.binding(get:\.birthday, send: SignUp.Action.birthdayChanged), in: ...Date.now, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                            .frame(maxWidth:.infinity)
                            .background(Color.white)
                            .cornerRadius(8)
                        
                    }
                    
                    Button("회원가입"){
                        viewStore.send(.signUp)
                    }.buttonStyle(VitalWinkButtonStyle(isDisabled: viewStore.isSignUpButtonDisabled))
                    .disabled(viewStore.isSignUpButtonDisabled)
                }
                .padding(.top, 25)
                .padding(.horizontal, 20)
            }
            .background(Color.backgroundColor)
            .navigationTitle(Text("회원가입"))
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
            .vitalWinkAlert(store.scope(state: \.property.alertState, action: {$0}), dismiss: .alertDismiss)
            .activityIndicator(isVisible: viewStore.isActivityIndicatorVisible)
            .onChange(of: viewStore.shouldViewDismiss){
                if $0{
                    dismiss()
                }
            }
            .onDisappear{
                viewStore.send(.onDisappear)
            }
            .onAppear{
                viewStore.send(.onAppear)
            }
        }
        
    }
    
    @Environment(\.dismiss) private var dismiss   
    private let store: StoreOf<SignUp>
}


struct SignUpView_Previews: PreviewProvider{
    static var previews: some View{
        SignUpView(store: Store(initialState: User.State(), reducer: User()))
    }
}
