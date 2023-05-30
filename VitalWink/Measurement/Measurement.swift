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

struct Measurement: ReducerProtocol{
    struct State{
        fileprivate var bgrValues = [(Int, Int, Int)]()
        //최근 측정에 대한 Id
        fileprivate var measurementId: Int? = nil
        public private(set) var target: Target = .face
    }
    
    enum Target{
        case face
        case finger
    }
    
    enum Action{
        case signalMeasurement
        case responseSignalMeasurement(Result<Int, Error>)
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
                            send.send(.responseSignalMeasurement(.failure(error)))
                        }
                    }, receiveValue: {
                        send.send(.responseSignalMeasurement(.success($0)))
                    })
            }
        case .responseSignalMeasurement(let result):
            switch result{
            case .success(let measurementId):
                state.measurementId = measurementId
            case .failure(let error):
                print(error.localizedDescription)
            }
            return .none
        }
    }
    
    
    //MARK: private
    @Dependency(\.measurementAPI) private var measurementAPI
    
}
