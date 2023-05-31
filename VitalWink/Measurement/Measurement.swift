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
struct Measurement: ReducerProtocol{
    typealias BGR = (Int, Int, Int)
    
    struct State{
        fileprivate var bgrValues = [BGR]()
        //최근 측정에 대한 Id
        public fileprivate(set) var measurementId: Int? = nil
        public private(set) var target: Target = .face
    }

    enum Target{
        case face
        case finger
    }
    
    enum Action{
        case appendBgrValues(_ frame: UIImage)
        case signalMeasurement
        case response((inout State) -> EffectTask<Action>)
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
      
        case .appendBgrValues(let frame):
            return .run{send in
                faceDetector.detect(frame)
                    .sink(receiveCompletion: {
                        switch $0{
                        case .finished:
                            break
                        case .failure(let error):
                            send.send(.response{_ in
                                return EffectTask<Action>.send(.errorHandling(error))
                            })
                        }
                }, receiveValue: {
                    guard let cgImage = frame.cgImage?.cropping(to: $0) else{
                        send.send(.response{_ in
                            return  EffectTask<Action>.send(.errorHandling(MeasurementError.croppingError))
                        })
                        return
                    }
                    send.send(.response{
                        $0.bgrValues.append(faceDetector.skinSegmentation(UIImage(cgImage: cgImage)))
                        return .none
                    })
                })
            }

        case .response(let completion):
            return completion(&state)
        case .errorHandling(let error):
            print(error.localizedDescription)
            return .none
        }
    }
    
    //MARK: private
    @Dependency(\.faceDetector) private var faceDetector
    @Dependency(\.measurementAPI) private var measurementAPI
    
}
