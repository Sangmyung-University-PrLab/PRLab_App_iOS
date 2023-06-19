//
//  LoginView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/24.
//

import Foundation
import SwiftUI
import ComposableArchitecture
struct LoginView: View{
    
    init(store: StoreOf<Login>){
        self.store = store
    }
    
    var body: some View{
        WithViewStore(store, observe: {$0}){viewStore in
            NavigationView{
                VStack(spacing:0){
                    Spacer(minLength: 100)
                    
                    Text("LOGO")
                        .frame(width:92, height:37)
                        .padding(.top, 100)
                        .padding(.bottom, 50)
                    
                    TextField("아이디", text: viewStore.binding(\.$id))
                        .textFieldStyle(VitalWinkTextFieldStyle())
                        .padding(.bottom, 10)
                        
                    
                    SecureField("비밀번호", text: viewStore.binding(\.$password))
                        .textFieldStyle(VitalWinkTextFieldStyle())
                        .padding(.bottom, 30)
                    
                    Button("로그인"){
                        viewStore.send(.login(.general))
                    }
                    .disabled(viewStore.isLoginButtonDisabled)
                    .buttonStyle(VitalWinkButtonStyle(isDisabled: viewStore.isLoginButtonDisabled))
                  
                    HStack(spacing:10){

                        NavigationLink("회원가입", isActive: viewStore.binding(\.$shouldShowSignUpView)){
                            SignUpView(store: store.scope(state: \.user, action: Login.Action.user))
                        }.foregroundColor(.black)

                        Spacer()
                        
//                        NavigationLink("아이디 찾기"){
//                            FindIdView(store: store.scope(state: \.user, action: .user))
//                        }.foregroundColor(.black)
                        
                        Spacer()
                        
//                        NavigationLink("비밀번호 찾기"){
//                            FindPasswordView(store: store.scope(state: \.user, action: .user))
//                        }.foregroundColor(.black)
                    }
                    .font(.notoSans(size: 13, weight: .medium))
                    .padding(.vertical, 30)
                    .padding(.horizontal, 23)
                    
                    Divider()
                        .background(dividerColor)
                        .padding(.bottom, 30)
                    
                    HStack(spacing:0){
                        Circle()
                            .foregroundColor(Color(red: 0, green: 0.831372549019608, blue: 0.294117647058824))
                            .frame(width: snsButtonSize)
                            .overlay(
                                Image("naver_logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 12.98,height: 12.79)
                            )
                            .onTapGesture {
                                viewStore.send(.login(.naver))
                            }
                        
                        Spacer()
                        Circle()
                            .foregroundColor(Color(red: 0.980392156862745, green: 0.882352941176471, blue: 0))
                            .frame(width: snsButtonSize)
                            .overlay(
                                Image("kakao_logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 18.04,height: 16.57)
                            )
                            .onTapGesture {
                                viewStore.send(.login(.kakao))
                            }

                        Spacer()
                        Circle()
                            .foregroundColor(.white)
                            .frame(width: snsButtonSize)
                            .overlay(
                                Image("google_logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 19.25,height: 19.25)
                            )
                            .onTapGesture {
                                viewStore.send(.login(.google))
                            }

                        Spacer()
                        Image("apple_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: snsButtonSize)
                            .mask(Circle())
                            .onTapGesture {
                                viewStore.send(.login(.apple))
                            }
                    
                        
                    }.frame(maxWidth: .infinity)
                    .padding(.horizontal, 23)
                   
                    Spacer(minLength: 78)
                }
                .padding(.horizontal, 20)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color.backgroundColor)
                .ignoresSafeArea()
//                .activityIndicator(isVisible: viewStore.state.isActivityIndicatorVisible)
//                .vitalWinkAlert(store.scope(state: \.alertState, action: {$0}), dismiss: .dismiss)
                }
            }
        
    }
    
    //MARK: private
    private let store: StoreOf<Login>
    private let snsButtonSize: CGFloat = 35
    private let dividerColor = Color(red: 0.850980392156863, green: 0.850980392156863, blue: 0.850980392156863)
}

//struct LoginView_Previews: PreviewProvider{
//    static var previews: some View{
//        return LoginView(store: Store(initialState: Root.State().login, reducer: Login()))
//    }
//}
