//
//  User.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/17.
//

import Foundation

struct UserModel{
    let id: String
    let password: String
    let email: String
    let gender: Gender
    let birthday: Date
    let type: `Type`
    
    enum Gender: String, CaseIterable{
        case man = "man", woman = "woman"
    }
    
    enum `Type`: String{
        case kakao = "kakao"
        case google = "google"
        case naver = "naver"
        case apple = "apple"
        case general = "general"
    }
}
