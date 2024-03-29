//
//  FaceMeasurement.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/25.
//

import Foundation
import ComposableArchitecture
import SwiftUI
struct FaceMeasuremenet: ReducerProtocol{
    struct State{
//        fileprivate(set) var imageAnalysisStartTime = CFAbsoluteTimeGetCurrent()
        
        fileprivate(set) var bbox: CGRect? = nil
        fileprivate(set) var shouldAnalyImage = true
        fileprivate(set) var imageAnalysisData: ImageAnalysisData? = nil
        fileprivate(set) var isDetecting = false
    }
    
    enum Action{
        case imageAnalysis(UIImage)
        case obtainRGBValue(UIImage)
        case responseFaceDetction(CGRect)
        case errorHandling(Error)
        case faceDetect(UIImage)
        case appendRGBValue(Measurement.RGB)
        case appendImageAnalysisData(ImageAnalysisData)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action{
        case .appendImageAnalysisData(let data):
            state.imageAnalysisData = data
            return .none
        case .imageAnalysis(let image):
            state.shouldAnalyImage = false
            return .run{send in
                switch await measurementAPI.imageAnalysis(image){
                case .success(let data):
                    await send(.appendImageAnalysisData(data))
                case .failure(let error):
                    await send(.errorHandling(error))
                }
            }.cancellable(id:MeasurementCancelID.imageAnalysis, cancelInFlight: true)
        case .faceDetect(let image):
            if state.isDetecting{
                return .none
            }
            
            state.isDetecting = true
            return .run{send in
                do{
                    let bbox = try await faceDetector.detect(image)
                    await send(.responseFaceDetction(bbox))

                }catch{
                    await send(.errorHandling(error))
                }
            }
        case .responseFaceDetction(let bbox):
            state.bbox = bbox
            state.isDetecting = false
            return .none
        case .appendRGBValue:
            return .none
        case .errorHandling:
            return .none
        case .obtainRGBValue(let image):
            return .run{[bbox = state.bbox, shouldAnalyImage = state.shouldAnalyImage] send in
                guard let bbox = bbox else {
                    return
                }
                do{
                    guard let croppedImage = image.cgImage?.cropping(to: bbox) else{
                        throw MeasurementError.croppingError
                    }
                    
                    let rgbValue = faceDetector.skinSegmentation(UIImage(cgImage: croppedImage))
                    await send(.appendRGBValue(rgbValue))
                }
                catch{
                    await send(.errorHandling(error))
                }
                
                if shouldAnalyImage{
                    await send(.imageAnalysis(image))
                }
            }.cancellable(id:MeasurementCancelID.obtainRGBValue, cancelInFlight: true)
        }
    }

   
    @Dependency(\.measurementAPI) private var measurementAPI
    @Dependency(\.faceDetector) private var faceDetector
}
