//
//  Publisher + Extension.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/21.
//

import Foundation
import Combine

extension Publisher where Output == Never{
    func sink(receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) -> AnyCancellable{
        return self.sink(receiveCompletion: receiveCompletion, receiveValue: {_ in
            
        })
    }
}
