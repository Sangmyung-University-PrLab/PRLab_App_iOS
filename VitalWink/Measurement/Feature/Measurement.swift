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
            return lhs.property == rhs.property
        }
        var canMeasure: Bool{
            if property.target == .face{
                guard let bbox = faceMeasurement.bbox else{
                    return false
                }
                return !bbox.isEmpty
            }
            else{
                return fingerMeasurement.isBeTight
            }
        }
        fileprivate(set) var property = MeasurementProperty()
        fileprivate(set) var fingerMeasurement = FingerMeasurement.State()
        fileprivate(set) var monitoring = Monitoring.State()
        fileprivate(set) var faceMeasurement = FaceMeasuremenet.State()
        fileprivate(set) var alert = MeasurementAlert.State()
    }
    
    
    enum Target: CaseIterable{
        case face
        case finger
    }
    
    enum Action{
        case changeTarget(Target)
        case startCamera
        case changeCamera
        case beFedFrame(_ sampleBuffer: CMSampleBuffer)
        case obtainRGBValue(UIImage)
        
        case startMeasurement
        case endMeasurement
        
        case reset
        case sendRGBValues
        case sendImageAnalysisData(_ measurementId: Int)
        case updateProgress
        
        case cancelMeasurement
        case fetchResult(_ measurementId: Int)
        case onDisappear
        case shouldShowReferenceView(Bool)
        
        case monitoring(Monitoring.Action)
        case alert(MeasurementAlert.Action)
        case menu(Menu.Action)
        case faceMeasurement(FaceMeasuremenet.Action)
        case fingerMeasurement(FingerMeasurement.Action)
    }
    
    var body: some ReducerProtocol<State, Action>{
        Reduce{state, action in
            switch action{
            case .changeCamera:
                return .run{send in
                    try camera.changeCameraPosition()
                }catch: { error, send in
                    await send(.alert(.errorHandling(error)))
                }
            case .shouldShowReferenceView(let value):
                state.property.shouldShowReferenceView = value
                return .none
            case .fingerMeasurement(let action):
                switch action{
                case .appendRGBValue(let rgb):
                    state.property.rgbValues.append(rgb)
                    return .none
                case .errorHandling(let error):
                    return .send(.alert(.errorHandling(error)))
                default:
                    return .none
                }
            case .faceMeasurement(let action):
                switch action{
                case .appendRGBValue(let rgb):
                    state.property.rgbValues.append(rgb)
                    return .none
                case .errorHandling(let error):
                    return .send(.alert(.errorHandling(error)))
                default:
                    return .none
                }
            case .menu(let action):
                return .send(.alert(.menu(action)))
                
            case .alert(let action):
                switch action{
                case .shouldDismissRootView:
                    state.property.shouldDismiss = true
                    return .none
                case .shouldShowActivityIndicator:
                    state.property.isActivityIndicatorVisible = true
                    return .none
                case .showResult:
                    return .send(.reset)
                case .errorHandling:
                    return .send(.cancelMeasurement)
                case .shouldShowReferenceView:
                    state.property.shouldShowReferenceView = true
                    return .none
                default:
                    return .none
                }
            case .onDisappear:
                camera.stop()
                var coninuation: AsyncStream<UIImage>.Continuation!
                state.property.frame = AsyncStream{
                    coninuation = $0
                    
                }
                state.property.frameContinuation = coninuation
                state.property.target = .face
                return .run{send in
                    await send(.cancelMeasurement)
                    if camera.position == .back{
                        try camera.changeCameraPosition()
                    }
                }
                catch: {error, send in
                    await send(.alert(.errorHandling(error)))
                }
                .merge(with:.cancel(id: MeasurementCancelID.beFedFrame))
                
                
            case .monitoring:
                return .none
            case .changeTarget(let target):
                state.property.target = target
                do{
                    try camera.changeCameraPosition()
                }catch{
                    return .send(.alert(.errorHandling(error)))
                }
                return .none
                
            case .sendImageAnalysisData(let measurementId):
                return .run{[data = state.faceMeasurement.imageAnalysisDatas] send in
                        try await measurementAPI.saveImageAnalysisData(data: data, measurementId: measurementId)
                        await send(.fetchResult(measurementId))
                }catch: { error, send in
                    await send(.alert(.errorHandling(error)))
                }
            case .fetchResult(let measurementId):
                return .run{send in
                    switch await measurementAPI.fetchMeasurementResult(measurementId){
                    case .success(let result):
                        await send(.alert(.showResult(result)))
                        await send(.reset)
                    case .failure(let error):
                        await send(.alert(.errorHandling(error)))
                    }
                }
            case .sendRGBValues:
                state.property.isActivityIndicatorVisible = true
                
                return .run{[rgbValues = state.property.rgbValues, target = state.property.target] send in
                    switch await measurementAPI.signalMeasurment(rgbValues: rgbValues, target: target){
                    case .success(let id):
                        if target == .face{
                            await send(.sendImageAnalysisData(id))
                        }
                        else{
                            await send(.fetchResult(id))
                        }
                    case .failure(let error):
                        await send(.alert(.errorHandling(error)))
                    }
                }
                
            case .obtainRGBValue(let image):
                return .run{[target = state.property.target] send in
                    if target == .face{
                        await send(.faceMeasurement(.obtainRGBValue(image)))
                    }
                    else{
                        await send(.fingerMeasurement(.obtainRGBValue(image)))
                    }
                }
                
            case .beFedFrame(let buffer):
                let uiImage = UIImage(sampleBuffer: buffer)
                state.property.frameContinuation.yield(uiImage)
                
                return .run{[isMeasuring = state.property.isMeasuring, target = state.property.target] send in
                    
                    if target == .face{
                        await send(.faceMeasurement(.faceDetect(uiImage)))
                    }
                    else{
                        await send(.fingerMeasurement(.checkFingerisBeTight(uiImage)))
                    }
                    
                    if isMeasuring{
                        await send(.obtainRGBValue(uiImage))
                        await send(.updateProgress)
                    }
                }.cancellable(id: MeasurementCancelID.beFedFrame, cancelInFlight: true)
                
            case .endMeasurement:
                state.property.isMeasuring = false
                return .send(.sendRGBValues)
                
            case .reset:
                if state.property.target == .face{
                    state.faceMeasurement = FaceMeasuremenet.State()
                }
                else{
                    state.fingerMeasurement = FingerMeasurement.State()
                }
                state.property.reset()
                return .none
                
            case .startCamera:
                return .run{send in
                    try await camera.setUp()
                    camera.start()
                }
                catch:{error, send in
                    await send(.alert(.errorHandling(error)))
                }
                .concatenate(with: EffectTask<Action>.run{send in
                    for await buffer in camera.frame{
                        await send(.beFedFrame(buffer))
                    }
                })
                
            case .startMeasurement:
                state.property.isMeasuring = true
                state.property.measurementStartTime = CFAbsoluteTimeGetCurrent()
                
                return .run{send in
                    try await Task.sleep(nanoseconds: measuringDuriation)
                    await send(.endMeasurement)
                }.cancellable(id:MeasurementCancelID.startMeasurement, cancelInFlight: true)
            case .cancelMeasurement:
                return .cancel(id: MeasurementCancelID.obtainRGBValue)
                    .merge(with: .send(.reset))
                    .merge(with:  .cancel(id: MeasurementCancelID.startMeasurement))
                    .merge(with:  .cancel(id: MeasurementCancelID.imageAnalysis))
                
            case .updateProgress:
                state.property.progress = min(Float(CFAbsoluteTimeGetCurrent() - (state.property.measurementStartTime ?? CFAbsoluteTimeGetCurrent())) / Float(measuringDuriation / nanosecond), 1.0)
                return .none
            }
        }
        
        Scope(state: \.monitoring, action: /Action.monitoring){
            Monitoring()
        }
        Scope(state: \.alert, action: /Action.alert){
            MeasurementAlert()
        }
        Scope(state: \.faceMeasurement, action: /Action.faceMeasurement){
            FaceMeasuremenet()
        }
        Scope(state: \.fingerMeasurement, action: /Action.fingerMeasurement){
            FingerMeasurement()
        }
    }
    
    
    
    //MARK: private
    private let nanosecond: UInt64 =  1_000_000_000
    private let measuringDuriation: UInt64 =  1_000_000_000 * 15
    
    @Dependency(\.camera) private var camera
    @Dependency(\.measurementAPI) private var measurementAPI
}

