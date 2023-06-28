//
//  MonitoringRouter.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/28.
//

import Foundation
import Alamofire

enum MonitoringRouter: VitalWinkRouterType{
    
    case fetchRecentData
    case fetchMetricDatas(_ metric: Metric, period: Period, basisDate: Date)
    
    var endPoint: String{
        let baseEndPoint = "measurements"
        let detailEndPoint: String
        
        switch self{
        case .fetchRecentData:
            detailEndPoint = "recent"
        case .fetchMetricDatas(let metric, let period, let basisDate):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            detailEndPoint = "\(metric.rawValue)/\(period.rawValue)/\(dateFormatter.string(from: basisDate))"
        }
        
        return  "\(baseEndPoint)/\(detailEndPoint)"
    }
    
    var method: HTTPMethod{
        switch self{
        case .fetchRecentData,.fetchMetricDatas:
            return .get
    
        }
    }
    
    var parameters: Parameters{
        return Parameters()
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
