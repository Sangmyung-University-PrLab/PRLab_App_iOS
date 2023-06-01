//
//  MeasurementView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/30.
//

import SwiftUI
import ComposableArchitecture
import Combine
struct MeasurementView: View {
    let store: StoreOf<Measurement>
    @State var image = Image(uiImage: UIImage())

    var body: some View {
        WithViewStore(self.store, observe: {$0}){viewStore in
            VStack{
                image
                    .resizable()
                Button{
                    viewStore.send(.startCamera)
                }label: {
                    Text("camera start")
                }
                Button{
                    viewStore.send(.startMeasurement)
                }label: {
                    Text("measurment start")
                }
            }.onAppear{
                Task{
                    for await frame in viewStore.state.frame{
                        self.image = Image(uiImage: frame)
                    }
                }
                
            }
        }
    }
}

