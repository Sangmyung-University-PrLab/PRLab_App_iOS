//
//  MeasurementRouter.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/21.
//

import Foundation
import Alamofire

enum MeasurementRouter: VitalWinkUploadableRouterType{
    case signalMeasurement(rgbValues: [(Int, Int, Int)], target: Measurement.Target)
    case imageAnalysis(image: UIImage)
    case fetchMeasurementResult(_ id: Int)
    case saveImageAnalysisData(_ data: [ImageAnalysisData], _ measurementId: Int)
    
    var endPoint: String{
        let baseEndPoint = "measurements"
        let detailEndPoint: String
        switch self {
        case .signalMeasurement(_,let target):
            let targetString = target == .face ? "face" : "finger"
            detailEndPoint = "signal/\(targetString)"
        case .imageAnalysis:
            detailEndPoint = "expressionAndBMI"
        case .fetchMeasurementResult(let id):
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
        }
    }
    
    var parameters: Parameters{
        switch self{
        case .signalMeasurement(let rgbValues, _):
            return [
                "rgbValues": rgbValues.map{[$0.0, $0.1, $0.2]}
            ]
        case .saveImageAnalysisData(let data,_):
            var valanceAVG: Float = 0.0
            var arousalAVG: Float = 0.0
            var expressions = [String]()
            var BMIAVG = 0
            
            data.forEach{
                valanceAVG += $0.expressionAnalysisData.valence
                arousalAVG += $0.expressionAnalysisData.arousal
                expressions.append($0.expressionAnalysisData.expression)
                BMIAVG += $0.BMI
            }
            return [
                "bmi": BMIAVG,
                "valence" : valanceAVG,
                "arousal": arousalAVG,
                "expression": expressions
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
