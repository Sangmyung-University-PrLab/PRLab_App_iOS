//
//  VitalWinkAlert.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/09.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct VitalWinkAlert<Action>: View{
    init(viewStore: ViewStore<VitalWinkAlertState<Action>?, Action>, dismiss: Action){
        self.viewStore = viewStore
        self.dismiss = dismiss
    }
    
    var body: some View{
        VStack{
            Spacer()
            RoundedRectangle(cornerRadius: 10)
                .shadow(color: Color.black.opacity(0.2), radius: 10)
                .foregroundColor(.white)
            
                .overlay(alignment:.top){
                    VStack(alignment: .leading, spacing: 0){
                        Text(title)
                            .font(.notoSans(size: 12,weight: .medium))
                            .padding(.bottom, 10)
                        Divider()
                            .padding(.bottom,10)
                        
                        message
                            .font(.notoSans(size: 14,weight: .regular))
                            .padding(.bottom, 30)
                        
                        
                        if buttonStates.count == 1{
                            let button = buttonStates[0]
                            Button(button.title){
                                if let action = button.action(){
                                    viewStore.send(action)
                                }
                                viewStore.send(dismiss)
                            }.buttonStyle(VitalWinkButtonStyle())
                        }
                        else{
                            HStack{
                                ForEach(buttonStates){button in
                                    Button(button.title){
                                        if let action = button.action(){
                                            viewStore.send(action)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                }
                .frame(height: alertHeight)
                
        }
        .offset(y:!shouldPresent ? alertHeight : 0)
        .onChange(of: viewStore.state){
            guard let state = $0 else{
                shouldPresent = false
                return
            }
            title = state.title
            message = Text(LocalizedStringKey(state.message))
            buttonStates = state.buttons
            shouldPresent = true
        }
        
        .animation(.easeInOut, value: shouldPresent)
            
    }
    
    //MARK: private
    private let dismiss: Action
    private let alertHeight = 173 + (UIApplication.shared.safeAreaInsets?.bottom ?? 0)
    @ObservedObject private var viewStore: ViewStore<VitalWinkAlertState<Action>?, Action>
    @State private var shouldPresent = false
    @State private var title: String = ""
    @State private var message: Text = Text("")
    @State private var buttonStates: [VitalWinkAlertButtonState<Action>] = []
}

