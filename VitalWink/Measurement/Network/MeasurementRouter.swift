//
//  MeasurementRouter.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/21.
//

import Foundation
import Alamofire

enum MeasurementRouter: VitalWinkUploadableRouterType{
    case signalMeasurement(bgrValues: [(Int, Int, Int)], target: Measurement.Target)
    case expressionAndBMIMeasurement(image: UIImage, id: Int)
    case fetchRecentData
    case fetchMetricDatas(_ metric: Metric, period: Period, basisDate: Date)
    case fetchMeasurementResult(_ id: Int)
    
    var endPoint: String{
        let baseEndPoint = "measurements"
        let detailEndPoint: String
        switch self {
        case .signalMeasurement(_,let target):
            let targetString = target == .face ? "face" : "finger"
            detailEndPoint = "signal/\(targetString)"
        case .expressionAndBMIMeasurement:
            detailEndPoint = "expressionAndBMI"
        case .fetchRecentData:
            detailEndPoint = "recent"
        case .fetchMetricDatas(let metric, let period, let basisDate):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            detailEndPoint = "\(metric.rawValue)/\(period.rawValue)/\(dateFormatter.string(from: basisDate))"
        case .fetchMeasurementResult(let id):
            detailEndPoint = "\(id)"
        }
        
        return  "\(baseEndPoint)/\(detailEndPoint)"
    }
    
    var method: HTTPMethod{
        switch self {
        case .signalMeasurement, .expressionAndBMIMeasurement:
            return .post
        case .fetchRecentData, .fetchMetricDatas, .fetchMeasurementResult:
            return .get
        }
    }
    
    var parameters: Parameters{
        switch self{
        case .signalMeasurement(let bgrValues, _):
            return [
                "bgrValues": bgrValues.map{[$0.0, $0.1, $0.2]}
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
            formData.append(Data(bytes: &id, count: MemoryLayout<Int>.size), withName: "measurement_id")
        default:
            return
        }
    }
    enum Metric: String{
        case bpm = "bpms"
        case SpO2 = "SpO2s"
        case RR = "RRs"
        case stressIndex = "stressIndexs"
        case BMI = "BMIs"
        case expressionAnalysis = "expressionAnalyses"
        case bloodPressure = "bloodPressures"
        case bloodSugars = "bloodSugars"
    }
    
    enum Period: String{
        case day = "day"
        case week = "week"
        case month = "month"
        case year = "year"
    }
}
