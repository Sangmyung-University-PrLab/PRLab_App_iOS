//
//  User.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/17.
//

import Foundation

struct User{
    let id: String
    let password: String
    let email: String
    let gender: Gender
    let birthday: Date
    
    enum Gender: String{
        case man = "man", woman = "woman"
    }
}
