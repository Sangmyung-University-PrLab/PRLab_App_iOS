//
//  MetricDataResponse.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/22.
//

import Foundation
struct MetricDataResponse<ValueType>: DataBaseType where ValueType: DataBaseType {
    let datas: [MetricData<ValueType>]
}
