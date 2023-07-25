//
//  MeasurementState.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/25.
//

import Foundation
struct MeasurementProperty: Equatable{
    static func == (lhs: MeasurementProperty, rhs: MeasurementProperty) -> Bool {
        if lhs.rgbValues.count != rhs.rgbValues.count || lhs.target != rhs.target{
            return false
        }
        else{
            var result = true
            for (lvalue, rvalue) in zip(lhs.rgbValues, rhs.rgbValues){
                if lvalue != rvalue{
                    result = false
                    break
                }
            }
            return result
        }
    }
    
    init(){
        var coninuation: AsyncStream<UIImage>.Continuation!
        frame = AsyncStream{
            coninuation = $0
            
        }
        self.frameContinuation = coninuation
    }
    var frameContinuation: AsyncStream<UIImage>.Continuation
    
    //최근 측정에 대한 Id
    var target: Measurement.Target = .face
    var isActivityIndicatorVisible = false
    var canMeasure: Bool{
        if target == .face{
            guard let bbox = self.bbox else{
                return false
            }
            return !bbox.isEmpty
        }
        else{
            return isBeTight
        }
    }
    var shouldDismiss = false
    var frame: AsyncStream<UIImage>
    
    
    var isMeasuring: Bool = false
    var rgbValues = [Measurement.RGB]()
    var imageAnalysisDatas = [ImageAnalysisData]()
    var progress: Float = 0.0
    var measurementStartTime: CFAbsoluteTime? = nil
    var imageAnalysisStartTime: CFAbsoluteTime? = nil
    var bbox: CGRect? = nil
    var isBeTight = false
    
    mutating func reset(){
        measurementStartTime = nil
        imageAnalysisStartTime = nil
        rgbValues = []
        imageAnalysisDatas = []
        progress = 0
        bbox = nil
        shouldDismiss = false
        isActivityIndicatorVisible = false
    }
}
