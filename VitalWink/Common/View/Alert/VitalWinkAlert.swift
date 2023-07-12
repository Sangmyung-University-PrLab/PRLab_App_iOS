//
//  VitalWinkAlert.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/09.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct VitalWinkAlert<VAS>: View where VAS: VitalWinkAlertState{
    init(viewStore: ViewStore<VAS?, VAS.Action>, dismiss: VAS.Action){
        self.viewStore = viewStore
        self.dismiss = dismiss
    }
    var body: some View{
        VStack{
            Spacer()
                VStack(alignment: .leading, spacing: 0){
                    if content != nil{
                        content
                    }
                    if buttonStates.count == 1{
                        let button = buttonStates[0]
                        Button(button.title){
                            viewStore.send(dismiss)
                        }
                        .buttonStyle(VitalWinkButtonStyle())
                    }
                    
                    else{
                        VStack{
                            ForEach(buttonStates){button in
                                if button.role == .cancel{
                                    Button(button.title){
                                        viewStore.send(dismiss)
                                    }
                                    .buttonStyle(VitalWinkButtonStyle())
                                }
                                else{
                                    Button(button.title){
                                        if let action = button.action(){
                                            viewStore.send(action)
                                        }
                                        if button.role == .distructive{
                                            viewStore.send(dismiss)
                                        }
                                    }.buttonStyle(VitalWinkAlertPlainButtonStyle())
                                }
                               
                            }
                        }
                    }
                    
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background{
                    GeometryReader{proxy in
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.white)
                            .onChange(of: proxy.size.height){
                                alertHeight = $0
                            }.onAppear{
                                alertHeight = proxy.size.height
                            }
                    }
                }
                .offset(x:0,y: shouldPresent ? 0 : alertHeight)
                
                
               
            
           
        }
        .frame(maxHeight: .infinity)
        .onChange(of: viewStore.state){
            guard let state = $0 else{
                shouldPresent = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    buttonStates = []
                }
                return
            }
           
            content = state.content
            buttonStates = state.buttons
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                shouldPresent = true
            }
        }
        
        .animation(.easeInOut, value: shouldPresent)
            
    }
    
    //MARK: private
    private let dismiss: VAS.Action
    @State private var alertHeight: CGFloat = 0
    @ObservedObject private var viewStore: ViewStore<VAS?, VAS.Action>
    
    @State private var content: VAS.Content? = nil
    @State private var shouldPresent = false
    @State private var buttonStates: [VitalWinkAlertButtonState<VAS.Action>] = []
}

