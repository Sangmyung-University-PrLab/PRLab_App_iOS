//
//  VitalWinkAlert.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/09.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct VitalWinkAlertState<Action>: Equatable{
    init(title: String, message: String, @VitalWinkAlertButtonBuilder buttons: () -> [VitalWinkAlertButtonState<Action>]){
        self.title = title
        self.buttons = buttons()
        self.message = message
    }

    let title: String
    let message: String
    let buttons: [VitalWinkAlertButtonState<Action>]
    
    static func == (lhs: VitalWinkAlertState, rhs: VitalWinkAlertState) -> Bool {
        return lhs.title == rhs.title && lhs.message == rhs.message && lhs.buttons == rhs.buttons
    }
}

struct VitalWinkAlert<Action>: View{
    @ObservedObject var viewStore: ViewStore<VitalWinkAlertState<Action>?, Action>
    let dismiss:Action
    
    var body: some View{
        VStack{
            Spacer()
            RoundedRectangle(cornerRadius: 10)
                .shadow(color: Color.black.opacity(0.2), radius: 10)
                .foregroundColor(.white)
                .overlay{
                    VStack(alignment: .leading, spacing: 0){
                        Text(title)
                            .font(.notoSans(size: 12,weight: .medium))
                            .padding(.bottom, 10)
                        Divider()
                            .padding(.bottom,10)
                        Text(message)
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
                    }.padding(.horizontal, 20)
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
            message = state.message
            buttonStates = state.buttons
            shouldPresent = true
        }
        
        .animation(.easeInOut, value: shouldPresent)
            
    }
    
    //MARK: private 
    private let alertHeight = 173 + (UIApplication.shared.safeAreaInsets?.bottom ?? 0)
    @State private var shouldPresent = false
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var buttonStates: [VitalWinkAlertButtonState<Action>] = []
}

