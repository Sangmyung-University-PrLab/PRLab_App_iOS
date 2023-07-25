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
        
        fileprivate(set) var property = MeasurementProperty()
        
        fileprivate(set) var monitoring = Monitoring.State()
        fileprivate(set) var alert = MeasurementAlert.State()
    }

    
    enum Target: CaseIterable{
        case face
        case finger
    }
    
    enum Action{
        case changeTarget(Target)
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
        case updateProgress
        case responseFaceDetction(CGRect)
        case cancelMeasurement
        case fetchResult(_ measurementId: Int)
        case onDisappear
        case checkFingerisBeTight(UIImage)
        
        case monitoring(Monitoring.Action)
        case alert(MeasurementAlert.Action)
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
        Reduce{state, action in
            switch action{
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
                default:
                    return .none
                }
            case .checkFingerisBeTight(let image):
                state.property.isBeTight = OpenCVWrapper.isBeTight(image, 0.8)
                
                return .none
            case .onDisappear:
                camera.stop()
                var coninuation: AsyncStream<UIImage>.Continuation!
                state.property.frame = AsyncStream{
                    coninuation = $0
              
                }
                state.property.frameContinuation = coninuation
                
                return .send(.cancelMeasurement)
                    .merge(with:.cancel(id: CancelID.beFedFrame))
                   
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
                
     
            case .responseFaceDetction(let bbox):
                state.property.bbox = bbox
                return .none
            case .sendImageAnalysisData(let measurementId):
                return .run{[data = state.property.imageAnalysisDatas] send in
                    do{
                        try await measurementAPI.saveImageAnalysisData(data: data, measurementId: measurementId)
                        await send(.fetchResult(measurementId))
                    }catch{
                        await send(.alert(.errorHandling(error)))
                    }
                }
            case .fetchResult(let measurementId):
                return .run{send in
                    switch await measurementAPI.fetchMeasurementResult(measurementId){
                    case .success(let result):
                        await send(.alert(.showResult(result)))
                    case .failure(let error):
                        await send(.alert(.errorHandling(error)))
                    }
                }
            case .sendBgrValues:
                state.property.isActivityIndicatorVisible = true
                
                return .run{[rgbValues = state.property.rgbValues, target = state.property.target] send in
                    switch await measurementAPI.signalMeasurment(rgbValues: rgbValues, target: target){
                    case .success(let id):
                        await send(.sendImageAnalysisData(id))
                    case .failure(let error):
                        await send(.alert(.errorHandling(error)))
                    }
                }
        
            case .obtainBgrValue(let image):
                return .run{[target = state.property.target, bbox = state.property.bbox] send in
                    if target == .face{
                        guard let bbox = bbox else{
                            return
                        }
                        do{
                            guard let croppedImage = image.cgImage?.cropping(to: bbox) else{
                                throw MeasurementError.croppingError
                            }
                            
                            let bgrValue = faceDetector.skinSegmentation(UIImage(cgImage: croppedImage))
                            await send(.appendBgrValue(bgrValue))
                        }
                        catch{
                            await send(.alert(.errorHandling(error)))
                        }
                    }
                    else{
                        let nsArr = OpenCVWrapper.getBgrValues(image)
                        let rgb = (nsArr[0] as! Int, nsArr[1] as! Int, nsArr[2] as! Int)
                        await send(.appendBgrValue(rgb))
                    }
                }.cancellable(id:CancelID.obtainBgrValue, cancelInFlight: true)
            
            case .appendBgrValue(let rgb):
                state.property.rgbValues.append(rgb)
                return .none
            case .beFedFrame(let buffer):
                let uiImage = UIImage(sampleBuffer: buffer)
                state.property.frameContinuation.yield(uiImage)
                
                return .run{[imageAnalysisStartTime = state.property.imageAnalysisStartTime ?? CFAbsoluteTimeGetCurrent(), isMeasuring = state.property.isMeasuring, target = state.property.target] send in
                    
                    if target == .face{
                        do{
                            let bbox = try await faceDetector.detect(uiImage)
                            await send(.responseFaceDetction(bbox))
                        }catch{
                            await send(.alert(.errorHandling(error)))
                        }
                    }
                    else{
                        await send(.checkFingerisBeTight(uiImage))
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
                state.property.isMeasuring = false
                return .send(.sendBgrValues)
                
            case .reset:
                state.property.reset()
                return .none
            
            case .startCamera:
                return .run{send in
                    do{
                        try await camera.setUp()
                    }catch{
                        await send(.alert(.errorHandling(error)))
                    }
                    camera.start()
                }.concatenate(with: EffectTask<Action>.run{send in
                   
                    for await buffer in camera.frame{
                        await send(.beFedFrame(buffer))
                    }
                })
            case .startMeasurement:
                state.property.isMeasuring = true
                state.property.measurementStartTime = CFAbsoluteTimeGetCurrent()
                state.property.imageAnalysisStartTime = CFAbsoluteTimeGetCurrent()
                
                return .run{send in
                    try await Task.sleep(nanoseconds: measuringDuriation)
                    await send(.endMeasurement)
                }.cancellable(id:CancelID.startMeasurement, cancelInFlight: true)
            case .cancelMeasurement:
                state.property.isMeasuring = false
                state.property.isActivityIndicatorVisible = false
                return .cancel(id: CancelID.obtainBgrValue)
                    .merge(with: .send(.reset))
                    .merge(with:  .cancel(id: CancelID.startMeasurement))
                    .merge(with:  .cancel(id: CancelID.imageAnalysis))
                
            case .updateProgress:
                state.property.progress = min(Float(CFAbsoluteTimeGetCurrent() - (state.property.measurementStartTime ?? CFAbsoluteTimeGetCurrent())) / Float(measuringDuriation / nanosecond), 1.0)
                return .none
            case .imageAnalysis(let image):
                state.property.imageAnalysisStartTime = CFAbsoluteTimeGetCurrent()
                
                return .run{send in
                    switch await measurementAPI.imageAnalysis(image){
                    case .success(let data):
                        await send(.appendImageAnalysisData(data))
                    case .failure(let error):
                        await send(.alert(.errorHandling(error)))
                    }
                }.cancellable(id:CancelID.imageAnalysis, cancelInFlight: true)
            case .appendImageAnalysisData(let data):
                state.property.imageAnalysisDatas.append(data)
                return .none
            }
        }
        
        Scope(state: \.monitoring, action: /Action.monitoring){
            Monitoring()
        }
        Scope(state: \.alert, action: /Action.alert){
            MeasurementAlert()
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
    private let measuringDuriation: UInt64 =  1_000_000_000 * 15
    @Dependency(\.camera) private var camera
    @Dependency(\.faceDetector) private var faceDetector
    @Dependency(\.measurementAPI) private var measurementAPI
}

