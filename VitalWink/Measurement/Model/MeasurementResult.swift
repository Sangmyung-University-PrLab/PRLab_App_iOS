//
//  MeasurementResult.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/23.
//

import Foundation
struct MeasurementResult: Codable{
    let bpm: Int
    let SpO2: Int
    let RR: Int
    let stress: Int

    let BMI: Int?
    let expressionAnalysis: ImageAnalysisData?

    let bloodPressure: BloodPressure?
    let bloodSugar: Int?
    
    init(bpm: Int, SpO2: Int, RR: Int, stress: Int, BMI: Int? = nil, expressionAnalysis: ImageAnalysisData? = nil, bloodPressure: BloodPressure?  = nil, bloodSugar: Int? = nil) {
        self.bpm = bpm
        self.SpO2 = SpO2
        self.RR = RR
        self.stress = stress
        self.BMI = BMI
        self.expressionAnalysis = expressionAnalysis
        self.bloodPressure = bloodPressure
        self.bloodSugar = bloodSugar
    }
    
    
    #if DEBUG
    static let faceMeasurementMock =  MeasurementResult(bpm: 100, SpO2: 100, RR: 10, stress: 100, BMI: 100, expressionAnalysis: .init( expressionAnalysisData: .init(valence: 1, arousal: 1, expression: ""),BMI: 1))
    static let fingeMeasurementMock =  MeasurementResult(bpm: 100, SpO2: 100, RR: 10, stress: 100, bloodPressure: .init(SYS: 100, DIA: 100), bloodSugar: 100)
    #endif
}
