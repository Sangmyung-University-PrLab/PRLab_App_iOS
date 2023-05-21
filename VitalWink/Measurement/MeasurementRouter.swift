//
//  MeasurementRouter.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/21.
//

import Foundation
import Alamofire

enum MeasurmentRouter: VitalWinkRouterType{
    case signalMeasurement(frames: [[[UInt8]]], target: Target)
    
    var endPoint: String{
        let baseEndPoint = "measurements"
        switch self {
        case .signalMeasurement(_,let target):
            return "\(baseEndPoint)/signal/\(target.rawValue)"
        }
    }
    
    var method: HTTPMethod{
        switch self {
        case .signalMeasurement:
            return .post
        }
    }
    
    var parameters: Parameters{
        switch self{
        case .signalMeasurement(let frames, _):
            return [
                "frames": frames
            ]
        default:
            return Parameters()
        }
    }
    
    var queries: [URLQueryItem]{
        switch self{
        default:
            return []
        }
    }
    
    enum Target: String{
        case finger = "finger"
        case face = "face"
    }
}
