//
//  MeasurementError.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/25.
//

import Foundation

enum MeasurementError: LocalizedError{
    case croppingError
    var errorDescription: String?{
        switch self{
        case .croppingError:
            return "얼굴 이미지 크롭에 실패했습니다."
        }
    }
}
