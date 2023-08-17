//
//  Step.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/18.
//

import Foundation
enum Step: Comparable & Codable & Equatable{
    case normal
    case caution
    case danger
    
    var korean: String{
        switch self {
        case .normal:
            return "정상"
        case .caution:
            return "주의"
        case .danger:
            return "위험"
        }
    }
    
    static func BMI(value: Float) -> Step{
        if value <= 18{
            return .caution
        }
        else if value >= 24{
            return .danger
        }
        else{
            return .normal
        }
    }
    
    static func SpO2(value: Float) -> Step{
        if value >= 95{
            return .normal
        }
        else if value <= 94 && value >= 91{
            return .caution
        }
        else{
            return .danger
        }
    }
    static func SpO2(value: MinMaxType<Float>) -> MinMaxType<Step>{
     
        let minStep = SpO2(value: value.min)
        let maxStep = SpO2(value: value.max)
        
        return MinMaxType(min: maxStep,max: minStep)
    }
    static func bloodPressure(SYS: Float) -> Step{
        if SYS < 120{
            return Step.normal
        }
        else if SYS >= 120 && SYS <= 149{
            return Step.caution
        }
        else{
            return Step.danger
        }
    }
    static func bloodPressure(DIA: Float) -> Step{
        if DIA < 80{
            return Step.normal
        }
        else if DIA >= 80 && DIA <= 95{
            return Step.caution
        }
        else{
            return Step.danger
        }
    }
    static func bloodPressure(SYS: MinMaxType<Float>, DIA: MinMaxType<Float>) -> [MinMaxType<Step>]{
        let SYSStep = SYS.map{bloodPressure(SYS: $0)}
        let DIAStep = DIA.map{bloodPressure(DIA: $0)}
        
        return [SYSStep, DIAStep]
    }
    static func bloodSugar(value: MinMaxType<Float>) -> MinMaxType<Step>{
        return value.map{
           bloodSugar(value: $0)
        }
    }
    static func bloodSugar(value:Float) -> Step{
        if value <= 99{
            return .normal
        }
        else if value >= 100 && value <= 125{
            return .caution
        }
        else{
            return .danger
        }
    }
}
