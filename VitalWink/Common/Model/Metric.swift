//
//  Metric.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/03.
//

import Foundation
enum Metric: String{
    /*
        spo2: 90이하 위험 , 91 이상 94이하 주의, 95 정상
        혈압:
        혈당:
        BMI : 18이하 저체중, 19 ~ 23 정상, 24~ 과체중
     */
    
    case bpm = "bpms"
    case SpO2 = "SpO2s"
    case RR = "RRs"
    case stress = "stressIndexs"
    case BMI = "BMIs"
    case expressionAnalysis = "expressionAnalyses"
    case bloodPressure = "bloodPressures"
    case bloodSugars = "bloodSugars"
    
    var korean: String{
        switch self{
        case .bpm:
            return "심박수"
        case .SpO2:
            return "산소포화도"
        case .RR:
            return "분당 호흡수"
        case .stress:
            return "스트레스"
        case .BMI:
            return "BMI"
        case .expressionAnalysis:
            return "표정분석"
        case .bloodSugars:
            return "혈당"
        case .bloodPressure:
            return "혈압"
        }
    }
    var unit: String?{
        switch self{
        case .bpm:
            return "bpm"
        case .RR:
            return "회"
        default:
            return nil
        }
    }
    var min: Float{
        switch self{
        case .bpm:
            return 40
        case .SpO2:
            return 80
        case .RR:
            return 0
        case .expressionAnalysis:
            return -1
        case .BMI:
            return 10
        default:
            return 0
        }
    }
    var max: Float{
        switch self{
        case .bpm:
            return 220
        case .SpO2:
            return 99
        case .RR:
            return 40
        case .expressionAnalysis:
            return 1
        case .BMI:
            return 40
        default:
            return 0
        }
    }
}
