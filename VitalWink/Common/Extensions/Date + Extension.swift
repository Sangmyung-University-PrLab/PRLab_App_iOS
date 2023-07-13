//
//  Date + Extension.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/04.
//

import Foundation
extension Date{
    func dateArrayInPeriod(period: Period = .week) -> [Date]{
        var result = [self]
        var byAdding: Calendar.Component = .day
        var value = -1
        switch period {
//        case .day:
//            break
        case .week:
            break
        case .month:
            byAdding = .day
            value = -7
        case .year:
            byAdding = .month
        }
        
        for i in 0 ..< period.numberOfItem{
            result.append(Calendar.current.date(byAdding: byAdding, value: (i + 1) * value, to: self)!)
        }
    
        return result
    }
}
