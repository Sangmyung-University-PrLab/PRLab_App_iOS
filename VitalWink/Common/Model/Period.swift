//
//  Period.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/03.
//

import Foundation

enum Period: String, CaseIterable{
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
    
    var timeInterval: TimeInterval{
        var timeInterval: TimeInterval = 60 * 60
        switch self {
        case .day:
            timeInterval *= 24
        case .week:
            timeInterval *= 7 * 24
        case .month:
            timeInterval *= 4 * 7 * 24
        case .year:
            timeInterval *= 13 * 4 * 7 * 24
        }
        return timeInterval
    }
    
    var numberOfItem: Int{
        switch self {
        case .day:
            return 24
        case .week:
            return 7
        case .month:
            return 8
        case .year:
            return 12
        }
    
    }
}
