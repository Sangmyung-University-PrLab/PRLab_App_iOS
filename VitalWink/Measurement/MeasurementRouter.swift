//
//  MeasurementRouter.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/21.
//

import Foundation
import Alamofire

enum MeasurmentRouter: VitalWinkUploadableRouterType{
    case signalMeasurement(frames: [[[UInt8]]], target: Target)
    case expressionAndBMIMeasurement(image: UIImage, id: Int)
    case fetchRecentData
    
    var endPoint: String{
        let baseEndPoint = "measurements"
        let detailEndPoint: String
        switch self {
        case .signalMeasurement(_,let target):
            detailEndPoint = "signal/\(target.rawValue)"
        case .expressionAndBMIMeasurement:
            detailEndPoint = "expressionAndBMI"
        case .fetchRecentData:
            detailEndPoint = "recent"
        }
        
        return  "\(baseEndPoint)/\(detailEndPoint)"
    }
    
    var method: HTTPMethod{
        switch self {
        case .signalMeasurement, .expressionAndBMIMeasurement:
            return .post
        case .fetchRecentData:
            return .get
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
    
    func multipartFormData(_ formData: MultipartFormData) {
        switch self{
        case .expressionAndBMIMeasurement(image: let image, id: let id):
            formData.append(image.jpegData(compressionQuality: 0.5)!, withName: "image", mimeType: "image/jpeg")
            var id = id
            formData.append(Data(bytes: &id, count: MemoryLayout<Int>.size), withName: "measurment_id")
        default:
            return
        }
    }
    
    
    enum Target: String{
        case finger = "finger"
        case face = "face"
    }
}
