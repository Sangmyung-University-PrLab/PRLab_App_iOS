//
//  Measurement.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/30.
//

import Foundation
import ComposableArchitecture
import Dependencies
import Combine
import Alamofire
import OSLog

@preconcurrency import SwiftUI
@preconcurrency import CoreMedia

struct Measurement: ReducerProtocol{
    typealias RGB = (Int, Int, Int)
    
    struct State: Equatable{
        static func == (lhs: Measurement.State, rhs: Measurement.State) -> Bool {
            if lhs.rgbValues.count != rhs.rgbValues.count || lhs.target != rhs.target{
                return false
            }
            else{
                var result = true
                for (lvalue, rvalue) in zip(lhs.rgbValues, rhs.rgbValues){
                    if lvalue != rvalue{
                        result = false
                        break
                    }
                }
                return result
            }
        }
        init(){
            var coninuation: AsyncStream<UIImage>.Continuation!
            frame = AsyncStream{
                coninuation = $0
          
            }
            self.frameContinuation = coninuation
        }
        
        //최근 측정에 대한 Id
        @BindingState var target: Target = .face
        fileprivate(set) var isActivityIndicatorVisible = false
        fileprivate(set) var shouldDismiss = false
        fileprivate(set) var frame: AsyncStream<UIImage>
        var frameContinuation: AsyncStream<UIImage>.Continuation
        
        fileprivate(set) var monitoring = Monitoring.State()
        fileprivate(set) var menu = Menu.State()
        
        fileprivate(set) var resultAlertState: VitalWinkContentAlertState<MeasurementResultView,Action>? = nil
        fileprivate(set) var alertState: VitalWinkAlertMessageState<Action>? = nil
        fileprivate(set) var menuAlertState: VitalWinkMenuAlertState<Action>? = nil
        fileprivate(set) var isMeasuring: Bool = false
        fileprivate(set) var rgbValues = [RGB]()
        fileprivate(set) var imageAnalysisDatas = [ImageAnalysisData]()
        fileprivate(set) var progress: Float = 0.0
        fileprivate(set) var measurementStartTime: CFAbsoluteTime? = nil
        fileprivate(set) var imageAnalysisStartTime: CFAbsoluteTime? = nil
        fileprivate(set) var bbox: CGRect? = nil
       
    }
    
    enum Target: CaseIterable{
        case face
        case finger
    }
    
    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case startCamera
        case beFedFrame(_ sampleBuffer: CMSampleBuffer)
        case obtainBgrValue(UIImage)
        case appendBgrValue(RGB)
        case appendImageAnalysisData(ImageAnalysisData)
        case startMeasurement
        case endMeasurement
        case imageAnalysis(UIImage)
        case reset
        case sendBgrValues
        case sendImageAnalysisData(_ measurementId: Int)
        case errorHandling(Error)
        case updateProgress
        case responseFaceDetction(CGRect)
        case cancelMeasurement
        case alertDismiss
        case resultAlertDismiss
        case menuAlertAppear
        case menuAlertDismiss
        case fetchResult(_ measurementId: Int)
        case showResult(_ result: MeasurementResult)
        case onDisappear
        case monitoring(Monitoring.Action)
        case menu(Menu.Action)
    }
    
    enum MeasurementError: LocalizedError{
        case croppingError
        var errorDescription: String?{
            switch self{
            case .croppingError:
                return "얼굴 이미지 크롭에 실패했습니다."
            }
        }
    }
    
    var body: some ReducerProtocol<State, Action>{
        BindingReducer()
        
        Reduce{state, action in
            switch action{
            case .onDisappear:
                camera.stop()
                var coninuation: AsyncStream<UIImage>.Continuation!
                state.frame = AsyncStream{
                    coninuation = $0
              
                }
                state.frameContinuation = coninuation
                
                return .send(.cancelMeasurement)
                    .merge(with:.cancel(id: CancelID.beFedFrame))
                   
            case .monitoring:
                return .none
            case .binding:
                return .none
            case .responseFaceDetction(let bbox):
                state.bbox = bbox
                return .none
            case .sendImageAnalysisData(let measurementId):
                return .run{[data = state.imageAnalysisDatas] send in
                    do{
                        try await measurementAPI.saveImageAnalysisData(data: data, measurementId: measurementId)
                        await send(.fetchResult(measurementId))
                    }catch{
                        await send(.errorHandling(error))
                    }
                }
            case .fetchResult(let measurementId):
                return .run{send in
                    switch await measurementAPI.fetchMeasurementResult(measurementId){
                    case .success(let result):
                        await send(.showResult(result))
                    case .failure(let error):
                        await send(.errorHandling(error))
                    }
                }
            case .sendBgrValues:
                state.isActivityIndicatorVisible = true
                return .run{[rgbValues = state.rgbValues, target = state.target] send in
                    switch await measurementAPI.signalMeasurment(rgbValues: rgbValues, target: target){
                    case .success(let id):
                        await send(.sendImageAnalysisData(id))
                    case .failure(let error):
                        await send(.errorHandling(error))
                    }
                }
            case .showResult(let result):
                state.isActivityIndicatorVisible = false
                state.resultAlertState = VitalWinkContentAlertState{
                    VitalWinkAlertButtonState<Action>(title: "닫기"){
                        return nil
                    }
                }content: {
                    MeasurementResultView(result)
                }
                
                return .send(.reset)
            case .obtainBgrValue(let image):
                guard let bbox = state.bbox else{
                    return .none
                }
                
                return .run{send in
                    do{
                        guard let croppedImage = image.cgImage?.cropping(to: bbox) else{
                            throw MeasurementError.croppingError
                        }
                        
                        let bgrValue = faceDetector.skinSegmentation(UIImage(cgImage: croppedImage))
                        await send(.appendBgrValue(bgrValue))
                    }
                    catch{
                        await send(.errorHandling(error))
                    }
                }.cancellable(id:CancelID.obtainBgrValue, cancelInFlight: true)
            
            case .appendBgrValue(let rgb):
                state.rgbValues.append(rgb)
                return .none
            case .beFedFrame(let buffer):
                let uiImage = UIImage(sampleBuffer: buffer)
                state.frameContinuation.yield(uiImage)
                
                return .run{[imageAnalysisStartTime = state.imageAnalysisStartTime ?? CFAbsoluteTimeGetCurrent(), isMeasuring = state.isMeasuring] send in
                    do{
                        let bbox = try await faceDetector.detect(uiImage)
                        await send(.responseFaceDetction(bbox))
                    }catch{
                        await send(.errorHandling(error))
                    }
                    
                    if isMeasuring{
                        await send(.obtainBgrValue(uiImage))
                        await send(.updateProgress)
                        
                        if CFAbsoluteTimeGetCurrent() -  imageAnalysisStartTime >= 1.0{
                            await send(.imageAnalysis(uiImage))
                        }
                    }
                }.cancellable(id: CancelID.beFedFrame, cancelInFlight: true)
                
            case .endMeasurement:
                state.isMeasuring = false
                return .send(.sendBgrValues)
                
            case .reset:
                state.measurementStartTime = nil
                state.imageAnalysisStartTime = nil
                state.rgbValues = []
                state.imageAnalysisDatas = []
                state.progress = 0
                state.bbox = nil
                state.shouldDismiss = false
                state.isActivityIndicatorVisible = false
                return .none
            case .errorHandling(let error):
                let message = error.localizedDescription
                
                if state.isMeasuring{
                    state.alertState = .init(title: "측정", message: "측정 중 오류가 발생했습니다."){
                        VitalWinkAlertButtonState<Action>(title: "확인"){
                            return nil
                        }
                    }
                }
                else{
                    state.alertState = .init(title: "측정", message: message){
                        VitalWinkAlertButtonState<Action>(title: "확인"){
                            return nil
                        }
                    }
                }
                
                os_log(.error, log:.measurement,"%@", message)
                
                return .send(.cancelMeasurement)
                
            case .startCamera:
                return .run{send in
                    do{
                        try await camera.setUp()
                    }catch{
                        await send(.errorHandling(error))
                    }
                    camera.start()
                }.concatenate(with: EffectTask<Action>.run{send in
                   
                    for await buffer in camera.frame{
                        await send(.beFedFrame(buffer))
                    }
                })
            case .startMeasurement:
                state.isMeasuring = true
                state.measurementStartTime = CFAbsoluteTimeGetCurrent()
                state.imageAnalysisStartTime = CFAbsoluteTimeGetCurrent()
                
                return .run{send in
                    try await Task.sleep(nanoseconds: measuringDuriation)
                    await send(.endMeasurement)
                }.cancellable(id:CancelID.startMeasurement, cancelInFlight: true)
            case .cancelMeasurement:
                state.isMeasuring = false
                state.isActivityIndicatorVisible = false
                return .cancel(id: CancelID.obtainBgrValue)
                    .merge(with: .send(.reset))
                    .merge(with:  .cancel(id: CancelID.startMeasurement))
                    .merge(with:  .cancel(id: CancelID.imageAnalysis))
                
            case .updateProgress:
                state.progress = min(Float(CFAbsoluteTimeGetCurrent() - (state.measurementStartTime ?? CFAbsoluteTimeGetCurrent())) / Float(measuringDuriation / nanosecond), 1.0)
                return .none
            case .imageAnalysis(let image):
                state.imageAnalysisStartTime = CFAbsoluteTimeGetCurrent()
                
                return .run{send in
                    switch await measurementAPI.imageAnalysis(image){
                    case .success(let data):
                        await send(.appendImageAnalysisData(data))
                    case .failure(let error):
                        await send(.errorHandling(error))
                    }
                }.cancellable(id:CancelID.imageAnalysis, cancelInFlight: true)
            case .appendImageAnalysisData(let data):
                state.imageAnalysisDatas.append(data)
                return .none
            case .resultAlertDismiss:
                state.resultAlertState = nil
                return .none
            case .alertDismiss:
                state.alertState = nil
                return .none
            case .menuAlertAppear:
                state.menuAlertState = VitalWinkMenuAlertState{
                    VitalWinkAlertButtonState<Action>(title: "로그아웃", role: .distructive){
                        return .menu(.logout)
                    }
                    VitalWinkAlertButtonState<Action>(title: "회원탈퇴", role: .distructive){
                        return .menu(.withdrawal)
                    }
                    VitalWinkAlertButtonState<Action>(title: "닫기", role: .cancel){
                        return nil
                    }
                }
                return .none
            case .menuAlertDismiss:
                state.menuAlertState = nil
                return .none
            case .menu(let action):
                switch action{
                case .errorHandling(let error):
                    return .send(.errorHandling(error))
                case .confirmationWithdrawal:
                    state.isActivityIndicatorVisible = true
                    return .none
                case .shouldDismiss:
                    state.shouldDismiss = true
                    return .none
                case .failDeleteToken:
                    return .send(.menuAlertDismiss)
                default:
                    break
                }
                return .none
            }
        }
        
        Scope(state: \.monitoring, action: /Action.monitoring){
            Monitoring()
        }
        Scope(state:\.menu, action:/Action.menu){
            Menu()
        }
    }
    
    
    private enum CancelID:Hashable{
        case imageAnalysis
        case startMeasurement
        case obtainBgrValue
        case beFedFrame
    }
    //MARK: private
    private let nanosecond: UInt64 =  1_000_000_000
    private let measuringDuriation: UInt64 =  1_000_000_000 * 20
    @Dependency(\.camera) private var camera
    @Dependency(\.faceDetector) private var faceDetector
    @Dependency(\.measurementAPI) private var measurementAPI
}

