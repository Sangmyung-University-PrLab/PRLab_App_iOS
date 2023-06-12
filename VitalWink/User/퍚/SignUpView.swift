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
        self.store = store
    }
    var body: some View{
        WithViewStore(store, observe: {$0}){viewStore in
            ScrollView(.vertical, showsIndicators: false){
                VStack(alignment: .leading, spacing:30){
                    VitalWinkFormSection(header: "아이디",errorMessage: "아이디에 맞지 않는 형식입니다."){
                        HStack{
                            TextField("아이디", text: viewStore.binding(\.$id))
                                .textFieldStyle(VitalWinkTextFieldStyle())
                            
                            Button("중복검사"){
                                
                            }
                            .frame(width:75)
                            .buttonStyle(VitalWinkButtonStyle())
                        }
                    }
                    VitalWinkFormSection(header: "비밀번호",errorMessage: "아이디에 맞지 않는 형식입니다."){
                        TextField("비밀번호", text: viewStore.binding(\.$password))
                            .textFieldStyle(VitalWinkTextFieldStyle())
                    }
                    VitalWinkFormSection(header: "비밀번호 확인",errorMessage: "비밀번호 확인"){
                        TextField("비밀번호 확인", text: viewStore.binding(\.$repeatPassword))
                            .textFieldStyle(VitalWinkTextFieldStyle())
                    }
                    VitalWinkFormSection(header: "이메일",errorMessage: "아이디에 맞지 않는 형식입니다."){
                        TextField("이메일", text: viewStore.binding(\.$email))
                            .textFieldStyle(VitalWinkTextFieldStyle())
                    }
                    
                    VitalWinkFormSection(header: "성별"){
                        CircularSegmentedPickerView(selected: viewStore.binding(\.$gender), texts: ["남성", "여성"])
                    }
                    VitalWinkFormSection(header: "생년월일"){
                        DatePicker("", selection: viewStore.binding(\.$birthday), in: ...Date.now, displayedComponents: .date)
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
                }.padding(.horizontal, 20)
            }
            
            .background(Color.backgroundColor)
            .navigationTitle("회원가입")
            .navigationBarTitleDisplayMode(.inline)
            
        }
        
    }
    
    
    private let store: StoreOf<User>
}


struct SignUpView_Previews: PreviewProvider{
    static var previews: some View{
        SignUpView(store: Store(initialState: Root.State().user, reducer: User()))
    }
}
