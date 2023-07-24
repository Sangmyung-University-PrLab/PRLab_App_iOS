//
//  BloodPressureMetricValue.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/22.
//

import Foundation
struct BloodPressureMetricValue: DataBaseType{
    let SYS: MinMaxType<Int>
    let DIA: MinMaxType<Int>
    
    #if DEBUG
    static let mock = BloodPressureMetricValue(SYS: MinMaxType(min: 1, max: 100), DIA: MinMaxType(min: 1, max: 100))
    #endif
    
}
