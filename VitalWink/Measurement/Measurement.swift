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
        
        let frame: AsyncStream<UIImage>
        fileprivate(set) var monitoring = Monitoring.State()
        fileprivate(set) var alertState: VitalWinkContentAlertState<MeasurementResultView,Action>? = nil
        fileprivate(set) var isMeasuring: Bool = false
        fileprivate(set) var rgbValues = [RGB]()
        fileprivate(set) var imageAnalysisDatas = [ImageAnalysisData]()
        fileprivate(set) var progress: Float = 0.0
        fileprivate(set) var measurementStartTime: CFAbsoluteTime? = nil
        fileprivate(set) var imageAnalysisStartTime: CFAbsoluteTime? = nil
        fileprivate(set) var bbox: CGRect? = nil
        fileprivate let frameContinuation: AsyncStream<UIImage>.Continuation
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
        case fetchResult(_ measurementId: Int)
        case showResult(_ result: MeasurementResult)
        case monitoring(Monitoring.Action)
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
                return .run{[rgbValues = state.rgbValues, target = state.target] send in
                    switch await measurementAPI.signalMeasurment(rgbValues: rgbValues, target: target){
                    case .success(let id):
                        await send(.sendImageAnalysisData(id))
                    case .failure(let error):
                        await send(.errorHandling(error))
                    }
                }
            case .showResult(let result):
      
                state.alertState = VitalWinkContentAlertState{
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
                }
                
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
              
                return .none
            case .errorHandling(let error):
                print(error.localizedDescription)
               
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
            case .alertDismiss:
                state.alertState = nil
                return .none
            }
        }
        
        Scope(state: \.monitoring, action: /Action.monitoring){
            Monitoring()
        }
    }
    
    
    private enum CancelID:Hashable{
        case imageAnalysis
        case startMeasurement
        case obtainBgrValue
    }
    //MARK: private
    private let nanosecond: UInt64 =  1_000_000_000
    private let measuringDuriation: UInt64 =  1_000_000_000 * 20
    @Dependency(\.camera) private var camera
    @Dependency(\.faceDetector) private var faceDetector
    @Dependency(\.measurementAPI) private var measurementAPI
}

