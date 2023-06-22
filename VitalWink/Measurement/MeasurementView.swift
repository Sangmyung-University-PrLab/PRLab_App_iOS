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
    init(store: StoreOf<Measurement>){
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store, observe: {$0}){viewStore in
            VStack(spacing:0){
                CircularSegmentedPickerView(selected: viewStore.binding(\.$target), texts: ["얼굴","손가락"])
                
                RoundedRectangle(cornerRadius: 20)
                    .padding(.horizontal, 60)
                    .padding(.top,85)
                    .padding(.bottom, 10)
                    .foregroundColor(.white)
                ProgressView()
                    .progressViewStyle(.linear)
                    .padding(.bottom, 95)
                    .padding(.horizontal, 60)
                    .foregroundColor(.blue)
                
                Button("측정"){
                    
                }
                .buttonStyle(VitalWinkButtonStyle())
                .padding(.horizontal, 20)
            }
            .navigationBarBackButtonHidden()
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Image("calender")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20.76)
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Image(systemName: "ellipsis")
                        .font(.system(size: 12))
                }
            }.background(Color.backgroundColor)
            
        }
    }
    
    private let store: StoreOf<Measurement>
}
struct MeasurementView_Previews: PreviewProvider{
    static var previews: some View{
        MeasurementView(store: Store(initialState: Measurement.State(), reducer: Measurement()))
    }
}
