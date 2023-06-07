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
    typealias BGR = (Int, Int, Int)
    
    struct State: Equatable{
        static func == (lhs: Measurement.State, rhs: Measurement.State) -> Bool {
            if lhs.bgrValues.count != rhs.bgrValues.count || lhs.measurementId != rhs.measurementId || lhs.target != rhs.target{
                return false
            }
            else{
                var result = true
                for (lvalue, rvalue) in zip(lhs.bgrValues, rhs.bgrValues){
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
        private(set) var target: Target = .face
        let frame: AsyncStream<UIImage>
        
        fileprivate var isMeasuring: Bool = false
        fileprivate var bgrValues = [BGR]()
        fileprivate(set) var measurementId: Int? = nil
        fileprivate let frameContinuation: AsyncStream<UIImage>.Continuation
    }
    
    enum Target{
        case face
        case finger
    }
    
    enum Action: Sendable{
        case startCamera
        case beFedFrame(_ sampleBuffer: CMSampleBuffer)
        case appendBgrValue(_ uiImage: UIImage)
        case startMeasurement
        case signalMeasurement
        case response(@Sendable (inout State) -> EffectTask<Action>)
        case errorHandling(Error)
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
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action{
        case .signalMeasurement:
            return .run{[bgrValues = state.bgrValues, target = state.target] send in
                measurementAPI.signalMeasurment(bgrValues: bgrValues, type: target)
                    .sink(receiveCompletion: {
                        switch $0{
                        case .finished:
                            break
                        case .failure(let error):
                            send.send(.response{_ in
                                return .send(.errorHandling(error))
                            })
                        }
                    }, receiveValue: {value in
                        send.send(.response{
                            $0.measurementId = value
                            return .none
                        })
                    })
            }
        case .appendBgrValue(let image):
            return .run{send in
                do{
                    let bbox = try await faceDetector.detect(image)
                    guard let croppedImage = image.cgImage?.cropping(to: bbox) else{
                        throw MeasurementError.croppingError
                    }
                    
                    let bgrValue = faceDetector.skinSegmentation(UIImage(cgImage: croppedImage))
                    
                    await send(.response{
                        $0.bgrValues.append(bgrValue)
                        return .none
                    })
                }
                catch{
                    await send(.errorHandling(error))
                }
            }
        case .beFedFrame(let buffer):
            let uiImage = UIImage(sampleBuffer: buffer)
            state.frameContinuation.yield(uiImage)

            return state.isMeasuring ? .send(.appendBgrValue(uiImage)) : .none
          
        case .response(let completion):
            return completion(&state)
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
            
            return .run{send in
                try await Task.sleep(nanoseconds: measuringDuriation)
                await send(.response{
                    $0.isMeasuring = false
                    return .none
                })
            }
        }
        
    }
    private enum CancelID{}
    //MARK: private
    private let measuringDuriation: UInt64 = 1_000_000_000 * 1
    @Dependency(\.camera) private var camera
    @Dependency(\.faceDetector) private var faceDetector
    @Dependency(\.measurementAPI) private var measurementAPI
}

