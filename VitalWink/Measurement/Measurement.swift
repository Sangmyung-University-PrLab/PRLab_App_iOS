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
            if lhs.rgbValues.count != rhs.rgbValues.count || lhs.measurementId != rhs.measurementId || lhs.target != rhs.target{
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
        
        fileprivate(set) var isMeasuring: Bool = false
        fileprivate(set) var rgbValues = [RGB]()
        fileprivate(set) var progress: Float = 0.0
        fileprivate(set) var measurementId: Int? = nil
        fileprivate(set) var measurementStartTime: CFAbsoluteTime? = nil
        
        fileprivate let frameContinuation: AsyncStream<UIImage>.Continuation
        
        
        fileprivate var timer: Timer? = nil
        
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
        case startMeasurement
        case endMeasurement
        case imageAnalysis(UIImage)
        case reset
        case sendBgrValues
        case errorHandling(Error)
        case responseMeasurementId(Int)
        case updateProgress
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
            case .binding:
                return .none
            case .responseMeasurementId(let id):
                state.measurementId = id
                return .none
            case .sendBgrValues:
                return .run{[rgbValues = state.rgbValues, target = state.target] send in
                    switch await measurementAPI.signalMeasurment(rgbValues: rgbValues, target: target){
                    case .success(let id):
                        await send(.responseMeasurementId(id))
                    case .failure(let error):
                        await send(.errorHandling(error))
                    }
                    await send(.reset)
                }
                
            case .obtainBgrValue(let image):
                return .run{send in
                    do{
                        let bbox = try await faceDetector.detect(image)
                        guard let croppedImage = image.cgImage?.cropping(to: bbox) else{
                            throw MeasurementError.croppingError
                        }
                        
                        let bgrValue = faceDetector.skinSegmentation(UIImage(cgImage: croppedImage))
                        
                        await send(.appendBgrValue(bgrValue))
                    }
                    catch{
                        await send(.errorHandling(error))
                    }
                }
            
            case .appendBgrValue(let rgb):
                state.rgbValues.append(rgb)
                return .none
            case .beFedFrame(let buffer):
                let uiImage = UIImage(sampleBuffer: buffer)
                state.frameContinuation.yield(uiImage)
                
                return state.isMeasuring ? .run{send in
                    await send(.obtainBgrValue(uiImage))
                    await send(.updateProgress)
              
                    await send(.imageAnalysis(uiImage))
                } : .none
                
            case .endMeasurement:
                return .send(.sendBgrValues)
            case .reset:
                state.isMeasuring = false
                state.measurementStartTime = nil
                state.rgbValues = []
                state.progress = 0
                
                return .none
            case .errorHandling(let error):
                print(error.localizedDescription)
                return .none
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
                
                return .run{send in
                    try await Task.sleep(nanoseconds: measuringDuriation)
                    await send(.endMeasurement)
                }
            case .updateProgress:
                state.progress = min(Float(CFAbsoluteTimeGetCurrent() - (state.measurementStartTime ?? CFAbsoluteTimeGetCurrent())) / Float(measuringDuriation / nanosecond), 1.0)
                return .none
            case .imageAnalysis(let image):
                return .run{send in
                    do{
                        try await measurementAPI.expressionAndBMI(image: image)
                    }catch{
                        await send(.errorHandling(error))
                    }
                   
                }
            }
        }
    }
    private enum CancelID{}
    //MARK: private
    private let nanosecond: UInt64 =  1_000_000_000
    private let measuringDuriation: UInt64 =  1_000_000_000 * 20
    @Dependency(\.camera) private var camera
    @Dependency(\.faceDetector) private var faceDetector
    @Dependency(\.measurementAPI) private var measurementAPI
}

