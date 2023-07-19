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
       
    static func SpO2(value: MinMaxType<Float>) -> MinMaxType<Step>{
        let condition: (Float) -> Step = {
            if $0 >= 95{
                return .normal
            }
            else if $0 <= 94 && $0 >= 91{
                return .caution
            }
            else{
                return .danger
            }
        }
        let minStep = condition(value.min)
        let maxStep = condition(value.max)
        
        return MinMaxType(min: maxStep,max: minStep)
    }
    static func bloodPressure(SYS: MinMaxType<Float>, DIA: MinMaxType<Float>) -> [MinMaxType<Step>]{
        let SYSStep = SYS.map{
            if $0 < 120{
                return Step.normal
            }
            else if $0 <= 120 && $0 >= 129{
                return Step.caution
            }
            else{
                return Step.danger
            }
        }
        let DIAStep = DIA.map{
            if $0 < 80{
                return Step.normal
            }
            else if $0 >= 80 && $0 <= 89{
                return Step.caution
            }
            else{
                return Step.danger
            }
        }
        
        return [SYSStep, DIAStep]
    }
    static func bloodSugar(value: MinMaxType<Float>) -> MinMaxType<Step>{
        return value.map{
            if $0 <= 99{
                return .normal
            }
            else if $0 >= 100 && $0 <= 125{
                return .caution
            }
            else{
                return .danger
            }
        }
    }
}
