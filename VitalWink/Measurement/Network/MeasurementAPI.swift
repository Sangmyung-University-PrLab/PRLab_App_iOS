//
//  MeasurementAPI.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/21.
//

import Foundation
import Dependencies
import Alamofire
import Combine
import SwiftyJSON

final class MeasurmentAPI{
    func deleteResult(_ id: Int) async throws{
        return try await withCheckedThrowingContinuation{continuation in
            vitalWinkAPI.request(MeasurementRouter.deleteResult(id)).response{
                switch $0.result{
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func signalMeasurment(rgbValues: [(Float, Float, Float)], target: Measurement.Target) async -> Result<Int, Error>{

        return await withCheckedContinuation{continuation in
            vitalWinkAPI.request(MeasurementRouter.signalMeasurement(rgbValues: rgbValues, target: target)).validate(statusCode: 200 ..< 300)
                .responseDecodable(of: JSON.self){
                    switch $0.result{
                    case .success(let json):
                        let id = json["measurementId"]
                        
                        guard id.error == nil else{
                            continuation.resume(returning: .failure(id.error!))
                            return
                        }
                        
                        continuation.resume(returning: .success(id.intValue))
                    case .failure(let error):
                        continuation.resume(returning: .failure(error))
                    }
                }
        }
    }
    func imageAnalysis(_ image: UIImage) async -> Result<ImageAnalysisData, AFError>{
        return await withCheckedContinuation{continuation in
            vitalWinkAPI.upload(MeasurementRouter.imageAnalysis(image:image))
                .validate(statusCode: 200 ..< 300)
                .responseDecodable(of:ImageAnalysisData.self){
                    switch $0.result{
                    case .success(let data):
                        continuation.resume(returning: .success(data))
                    case .failure(let error):
                        continuation.resume(returning: .failure(error))
                    }
                }
        }
    }
    func saveImageAnalysisData(data: ImageAnalysisData, measurementId: Int) async throws{
        return try await withCheckedThrowingContinuation{continuation in
            vitalWinkAPI.request(MeasurementRouter.saveImageAnalysisData(data, measurementId)).validate(statusCode: 200 ..< 300)
                .response{
                    switch $0.result{
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    func fetchMeasurementResult(_ id: Int) async -> Result<MeasurementResult, Error>{
        return await withCheckedContinuation{ continuation in
            vitalWinkAPI.request(MeasurementRouter.fetchMeasurementResult(id))
                .validate(statusCode: 200 ..< 300)
                .responseDecodable(of: MeasurementResult.self){
                    switch $0.result{
                    case .success(let data):
                        continuation.resume(returning: .success(data))
                    case .failure(let error):
                        continuation.resume(returning: .failure(error))
                    }
                }
        }
    }
    @Dependency(\.vitalWinkAPI) private var vitalWinkAPI
}

extension MeasurmentAPI: DependencyKey{
    static var liveValue: MeasurmentAPI = MeasurmentAPI()
    static var testValue: MeasurmentAPI = MeasurmentAPI()
}
