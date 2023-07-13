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
                    if !viewStore.isMeasuring{
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
                        .background{
                            NavigationLink("", isActive: $shouldShowRecentDataView){
                                RecentDataView(store: store.scope(state: \.monitoring, action: Measurement.Action.monitoring))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            shouldShowRecentDataView = true
                        }
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Image(systemName: "ellipsis")
                        .font(.system(size: 12))
                        .frame(width: 25, height: 25)
                        .containerShape(Rectangle())
                        .onTapGesture {
                            
                            viewStore.send(.menuAlertAppear)
                        }
                }
            }
            .padding(.horizontal, 20)
            .vitalWinkAlert(store.scope(state: \.alertState, action: {$0}), dismiss: .alertDismiss)
            .vitalWinkAlert(store.scope(state: \.resultAlertState, action: {$0}), dismiss: .resultAlertDismiss)
            .vitalWinkAlert(store.scope(state: \.menuAlertState, action: {$0}), dismiss: .menuAlertDismiss)
            .confirmationDialog(store.scope(state: \.menu.dialog, action: Measurement.Action.menu), dismiss: .dialogDismiss)
            .activityIndicator(isVisible: viewStore.isActivityIndicatorVisible)
            .navigationBarBackButtonHidden()
            .background(Color.backgroundColor)
            .onAppear{
                viewStore.send(.startCamera)
                frameTask = Task{
                    for await frame in viewStore.frame{
                        self.image = Image(uiImage: UIImage(cgImage: frame.cgImage!, scale: 1, orientation: .leftMirrored))
                    }
                }
            }
            
            .onDisappear{
                viewStore.send(.onDisappear)
                guard let frameTask = self.frameTask else{
                    return
                }
                frameTask.cancel()
                self.frameTask = nil
                self.image = nil
            }
            .onChange(of: viewStore.shouldDismiss){
                if $0{
                    dismiss()
                }
            }
            
        }
    }
    
    //MARK: - private
    @State private var frameTask: Task<(), Never>? = nil
    @State private var shouldShowRecentDataView = false
    @State private var image: Image?
    @Environment(\.dismiss) private var dismiss
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
