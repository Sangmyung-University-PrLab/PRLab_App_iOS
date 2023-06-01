//
//  CameraDelegate.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/12.
//

import Foundation
import AVFoundation
import CoreGraphics

protocol CameraStreamDelegate: AnyObject{
    var frameContinuation: AsyncStream<CMSampleBuffer>.Continuation {get}
}
