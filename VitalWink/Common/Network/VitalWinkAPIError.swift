//
//  VitalWinkAPIError.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/18.
//

import Foundation


enum VitalWinkAPIError: LocalizedError, Error{
    case notFoundToken
    
    var errorDescription: String?{
        switch self{
        case .notFoundToken:
            return "토큰을 찾을 수 없습니다."
        }
    }
}
