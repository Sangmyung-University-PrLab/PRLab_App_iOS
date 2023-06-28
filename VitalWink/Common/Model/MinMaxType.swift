//
//  MinMaxType.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/23.
//

import Foundation
struct MinMaxType<T: Codable & Comparable & Equatable>: Codable, Equatable{
    var min: T{
        willSet{
            if newValue > max{
                fatalError("min이 max보다 클 수 없습니다.")
            }
        }
    }
    var max: T{
        willSet{
            if newValue < min{
                fatalError("min이 max보다 클 수 없습니다.")
            }
        }
    }
    
    init(min: T, max: T) {
        if min > max{
            fatalError("min이 max보다 클 수 없습니다.")
        }
        
        self.min = min
        self.max = max
        
      
    }
    public static func ==(lhs:Self, rhs: Self) -> Bool{
        return lhs.min == rhs.min && lhs.max == rhs.max
    }
}
