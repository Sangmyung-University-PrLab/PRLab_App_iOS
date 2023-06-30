//
//  ExpressionAnalysisMetricValueType.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/22.
//

import Foundation
struct ExpressionAnalysisMetricValue:DataBaseType{
    let arousal: MinMaxType<Float>
    let valence: MinMaxType<Float>
    let expression: Expression
    
    struct Expression: DataBaseType{
        let neutral: Float
        let happy: Float
        let smile: Float
        let suprise: Float
        let fear: Float
        let angry: Float
        let disgust: Float
        let scorn: Float
    }

    #if DEBUG
    static let mock =  ExpressionAnalysisMetricValue(arousal: .init(min: 0.1, max: 1.0), valence: .init(min: 0.1, max: 1.0), expression: .init(neutral: 1.0, happy: 1.0, smile: 1.0, suprise: 1.0, fear: 1.0, angry: 1.0, disgust: 1.0, scorn: 1.0))
    #endif
}