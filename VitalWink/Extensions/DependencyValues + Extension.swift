//
//  DependencyValues + Extension.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/12.
//

import Foundation
import Dependencies

extension DependencyValues{
    var faceDetector: FaceDetector{
        get{self[FaceDetector.self]}
        set{self[FaceDetector.self] = newValue}
    }
}
