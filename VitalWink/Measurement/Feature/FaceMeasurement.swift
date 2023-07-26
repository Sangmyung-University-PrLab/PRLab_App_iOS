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
        fileprivate(set) var imageAnalysisStartTime = CFAbsoluteTimeGetCurrent()
        fileprivate(set) var bbox: CGRect? = nil
        fileprivate(set) var imageAnalysisDatas = [ImageAnalysisData]()
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
            state.imageAnalysisDatas.append(data)
            return .none
        case .imageAnalysis(let image):
            state.imageAnalysisStartTime = CFAbsoluteTimeGetCurrent()
            
            return .run{send in
                switch await measurementAPI.imageAnalysis(image){
                case .success(let data):
                    await send(.appendImageAnalysisData(data))
                case .failure(let error):
                    await send(.errorHandling(error))
                }
            }.cancellable(id:MeasurementCancelID.imageAnalysis, cancelInFlight: true)
        case .faceDetect(let image):
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
            return .none
        case .appendRGBValue:
            return .none
        case .errorHandling:
            return .none
        case .obtainRGBValue(let image):
            return .run{[bbox = state.bbox, imageAnalysisStartTime = state.imageAnalysisStartTime] send in
                guard let bbox = bbox else {
                    return
                }
                do{
                    guard let croppedImage = image.cgImage?.cropping(to: bbox) else{
                        throw MeasurementError.croppingError
                    }
                    
                    let bgrValue = faceDetector.skinSegmentation(UIImage(cgImage: croppedImage))
                    await send(.appendRGBValue(bgrValue))
                }
                catch{
                    await send(.errorHandling(error))
                }
                
                if CFAbsoluteTimeGetCurrent() - imageAnalysisStartTime >= 1.0{
                    await send(.imageAnalysis(image))
                }
            }.cancellable(id:MeasurementCancelID.obtainRGBValue, cancelInFlight: true)
        }
    }

    @Dependency(\.measurementAPI) private var measurementAPI
    @Dependency(\.faceDetector) private var faceDetector
}
