//
//  ExpressionAnalysis.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/22.
//

import Foundation
struct ImageAnalysisData: Codable{
    let expressionAnalysisData: ExpressionAnalysisData
    let BMI: Int
    
    enum CodingKeys: String,CodingKey {
        case expressionAnalysisData = "expressionAnalysis"
        case BMI
    }
}
