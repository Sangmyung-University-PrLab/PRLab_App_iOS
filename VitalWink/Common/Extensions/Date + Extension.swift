//
//  Date + Extension.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/04.
//

import Foundation
extension Date{
    func dateArrayInPeriod(end: Date) -> [Date]{
        let dayTimeInterval = 60 * 60 * 24
        let isEndLateThanSelf = end.timeIntervalSince(self) > 0
        
        let earlyDate = isEndLateThanSelf ? self : end
        let lateDate = isEndLateThanSelf ? end : self
        var result = [earlyDate]
        
        for i in 1 ..< Int(lateDate.timeIntervalSince(earlyDate)) / dayTimeInterval{
            result.append(Date(timeInterval: Double(dayTimeInterval * i), since: earlyDate))
        }
        result.append(lateDate)
      
        return result
    }
}
