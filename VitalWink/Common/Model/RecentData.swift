//
//  RecentDataResponse.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/22.
//

import Foundation

struct RecentData: Codable, Equatable{
    let bpm: Int?
    let SpO2: Int?
    let RR: Int?
    let stress: Int?
    
    let BMI: Int?
    let expressionAnalysis: ExpressionAnalysisNumericData?
    let bloodPressure: BloodPressure?
    let bloodSugar: Int?
    
    #if DEBUG
    static let mock = RecentData(bpm: 100, SpO2: 100, RR: 10, stress: 10, BMI: 10, expressionAnalysis: .init(valence: 1, arousal: 1), bloodPressure: .init(SYS: 100, DIA: 70), bloodSugar: 100)
    #endif
}
