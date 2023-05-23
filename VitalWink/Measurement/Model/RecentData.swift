//
//  RecentDataResponse.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/22.
//

import Foundation

struct RecentData: Codable{
    let bpm: Int?
    let SpO2: Int?
    let RR: Int?
    let stressIndex: Int?
    
    let BMI: Int?
    let expressionAnalysis: ExpressionAnalysis?
    let bloodPressure: BloodPressure?
    let bloodSugar: Int?
    
    #if DEBUG
    static let mock = RecentData(bpm: 100, SpO2: 100, RR: 10, stressIndex: 10, BMI: 10, expressionAnalysis: .init(valence: 1.0, arousal: 1.0), bloodPressure: .init(SYS: 100, DIA: 70), bloodSugar: 100)
    #endif
}
