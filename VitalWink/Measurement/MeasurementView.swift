//
//  MeasurementView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/30.
//

import SwiftUI
import ComposableArchitecture
struct MeasurementView: View {
    let store: StoreOf<Measurement>
    var body: some View {
        WithViewStore(self.store, observe: {$0}){viewStore in
            Image(uiImage: viewStore.state.frame)
            Button{
                viewStore.send(.startCamera)
            }label: {
                Text("measurement")
            }
        }
    }
}

