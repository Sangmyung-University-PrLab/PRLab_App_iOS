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
    let store: StoreOf<Login>
    
    var body: some View{
        WithViewStore(self.store, observe: {$0}){viewStore in
            VStack{
                Button("Kakao"){
                    viewStore.send(.login(.kakao))
                }
                Button("Google"){
                    viewStore.send(.login(.google))
                }
            }
          
        }
    }
}
