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
    
    var vitalWinkAPI: VitalWinkAPI{
        get{self[VitalWinkAPI.self]}
        set{self[VitalWinkAPI.self] = newValue}
    }
    
    var keyChainManager: KeyChainManager{
        get{self[KeyChainManager.self]}
        set{self[KeyChainManager.self] = newValue}
    }
    var userAPI: UserAPI{
        get{self[UserAPI.self]}
        set{self[UserAPI.self] = newValue}
    }
    var measurementAPI: MeasurmentAPI{
        get{self[MeasurmentAPI.self]}
        set{self[MeasurmentAPI.self] = newValue}
    }
    var camera: Camera{
        get{self[Camera.self]}
        set{self[Camera.self] = newValue}
    }
}
