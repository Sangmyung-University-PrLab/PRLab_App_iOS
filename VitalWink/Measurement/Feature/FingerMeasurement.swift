//
//  FingerMeasurement.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/26.
//

import Foundation
import ComposableArchitecture

struct FingerMeasurement: ReducerProtocol{
    struct State{
        fileprivate(set) var isBeTight = false
    }
    
    enum Action{
        case checkFingerisBeTight(UIImage)
        case obtainRGBValue(UIImage)
        case errorHandling(Error)
        case appendRGBValue(Measurement.RGB)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action{
        case .errorHandling:
            return .none
        case .obtainRGBValue(let image):
            let nsArr = OpenCVWrapper.getBgrValues(image)
            let rgb = (nsArr[0] as! Int, nsArr[1] as! Int, nsArr[2] as! Int)
            return .send(.appendRGBValue(rgb))
                .cancellable(id: MeasurementCancelID.obtainRGBValue, cancelInFlight: true)
        case .appendRGBValue:
            return .none
        case .checkFingerisBeTight(let image):
            state.isBeTight = OpenCVWrapper.isBeTight(image, 0.8)
            return .none
        }
    }
}
