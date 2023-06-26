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
                
                
                if let image = self.image{
                    image
                        .resizable()
                        .cornerRadius(20)
                        .overlay{
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(viewStore.bbox == .zero ? .red : .clear, lineWidth: 1)
                        }
                        .modifier(FrameViewModifier())
                        
                }else{
                    RoundedRectangle(cornerRadius: 20)
                        .overlay{
                            Image("face_guide")
                                .resizable()
                                .aspectRatio( contentMode: .fit)
                                .padding(44)
                        }
                        .modifier(FrameViewModifier())
                        
                }
                   
                ProgressView(value: viewStore.progress)
                    .progressViewStyle(.linear)
                    .padding(.horizontal, 40)
                    .foregroundColor(.blue)
                    .padding(.bottom, 10)
                
                
                Text("얼굴이 인식되지 않습니다.")
                    .font(.notoSans(size: 14))
                    .foregroundColor(viewStore.bbox == .zero ? .red : .clear)
                    .padding(.bottom, 70)
                
                Button(viewStore.isMeasuring ? "취소" : "측정"){
                    if viewStore.isMeasuring{
                        viewStore.send(.startMeasurement)
                    }
                    else{
                        viewStore.send(.cancelMeasurement)
                    }
                }
                .disabled(viewStore.bbox == .zero)
                .buttonStyle(VitalWinkButtonStyle(isDisabled: viewStore.bbox == .zero))
                .padding(.bottom, 30)
                
            }
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
            }
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden()
            .background(Color.backgroundColor)
            .onAppear{
                viewStore.send(.startCamera)
                
                Task{
                    for await frame in viewStore.state.frame{
                        self.image = Image(uiImage: UIImage(cgImage: frame.cgImage!, scale: 1, orientation: .leftMirrored))
                    }
                }
                
            }
        }
    }
    
    //MARK: - private
    @State private var image: Image?
    private let store: StoreOf<Measurement>
}


struct FrameViewModifier: ViewModifier{
    func body(content: Content) -> some View {
        content
        .shadow(color: .black.opacity(0.1),radius: 10)
        .padding(.horizontal, 40)
        .padding(.top,85)
        .padding(.bottom, 10)
        .foregroundColor(.white)
        
    }
}

struct MeasurementView_Previews: PreviewProvider{
    static var previews: some View{
        MeasurementView(store: Store(initialState: Measurement.State(), reducer: Measurement()))
    }
}
