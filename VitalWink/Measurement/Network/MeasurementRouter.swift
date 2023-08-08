//
//  MeasurementRouter.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/21.
//

import Foundation
import Alamofire

enum MeasurementRouter: VitalWinkUploadableRouterType{
    case signalMeasurement(rgbValues: [(Float, Float, Float)], target: Measurement.Target)
    case imageAnalysis(image: UIImage)
    case fetchMeasurementResult(_ id: Int)
    case saveImageAnalysisData(_ data: ImageAnalysisData, _ measurementId: Int)
    case deleteResult(_ id: Int)
    
    var endPoint: String{
        let baseEndPoint = "measurements"
        let detailEndPoint: String
        switch self {
        case .signalMeasurement(_,let target):
            let targetString = target == .face ? "face" : "finger"
            detailEndPoint = "signal/\(targetString)"
        case .imageAnalysis:
            detailEndPoint = "expressionAndBMI"
        case .fetchMeasurementResult(let id), .deleteResult(let id):
            detailEndPoint = "\(id)"
        case .saveImageAnalysisData(_, let measurementId):
            detailEndPoint = "expressionAndBMI/\(measurementId)"
        }
        
        return  "\(baseEndPoint)/\(detailEndPoint)"
    }
    
    var method: HTTPMethod{
        switch self {
        case .signalMeasurement, .imageAnalysis, .saveImageAnalysisData:
            return .post
        case .fetchMeasurementResult:
            return .get
        case .deleteResult:
            return .delete
        }
    }
    
    var parameters: Parameters{
        switch self{
        case .signalMeasurement(let rgbValues, _):
            return [
                "rgbValues": rgbValues.map{[$0.0, $0.1, $0.2]}
            ]
        case .saveImageAnalysisData(let data,_):
            return [
                "bmi": data.BMI,
                "valence" : data.expressionAnalysisData.valence,
                "arousal": data.expressionAnalysisData.arousal,
                "expression": data.expressionAnalysisData.expression
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
        case .imageAnalysis(image: let image):
            formData.append(image.jpegData(compressionQuality: 0.5)!, withName: "image", fileName: "image.jpg",mimeType: "image/jpeg")
        default:
            return
        }
    }
}
