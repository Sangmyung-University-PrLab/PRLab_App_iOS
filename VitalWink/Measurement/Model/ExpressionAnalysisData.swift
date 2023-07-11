//
//  ExpressionAnalsysisData.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/25.
//

import Foundation
struct ExpressionAnalysisData: Codable{
    let valence: Float
    let arousal: Float
    let expression: String
}
