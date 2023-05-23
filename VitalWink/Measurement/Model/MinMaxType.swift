//
//  MinMaxType.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/23.
//

import Foundation
struct MinMaxType<T: Codable>: Codable{
    let min: T
    let max: T
}
