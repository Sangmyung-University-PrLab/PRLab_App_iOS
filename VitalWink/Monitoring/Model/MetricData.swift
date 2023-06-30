//
//  MetricData.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/22.
//

import Foundation
struct MetricData<ValueType>: DataBaseType where ValueType: DataBaseType{
    let value: ValueType
    let basisDate: Date
    
    init(value: ValueType, basisDate: Date){
        self.value = value
        self.basisDate = basisDate
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<MetricData<ValueType>.CodingKeys> = try decoder.container(keyedBy: MetricData<ValueType>.CodingKeys.self)
        self.value = try container.decode(ValueType.self, forKey: MetricData<ValueType>.CodingKeys.value)
        let dateString = try container.decode(String.self, forKey: MetricData<ValueType>.CodingKeys.basisDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.basisDate = dateFormatter.date(from: dateString)!
    }
}
