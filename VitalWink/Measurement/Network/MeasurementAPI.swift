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
    func signalMeasurment(rgbValues: [(Int, Int, Int)], target: Measurement.Target) async -> Result<Int, Error>{
        
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
    func saveImageAnalysisData(data: [ImageAnalysisData], measurementId: Int) async throws{
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
    
    func fetchRecentData() -> AnyPublisher<RecentData, some Error>{
        return vitalWinkAPI.request(MeasurementRouter.fetchRecentData)
            .validate(statusCode: 200...200)
            .publishDecodable(type: RecentData.self)
            .value()
            .eraseToAnyPublisher()
    }
    
    func fetchMetricDatas<ValueType>(_ metric: MeasurementRouter.Metric, period: MeasurementRouter.Period, basisDate: Date, valueType: ValueType.Type = ValueType.self) -> AnyPublisher<[MetricData<ValueType>], some Error> where ValueType: Codable{
   
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return vitalWinkAPI.request(MeasurementRouter.fetchMetricDatas(metric, period: period, basisDate: basisDate))
            .validate(statusCode: 200...200)
            .publishDecodable(type: MetricDataResponse<ValueType>.self, decoder: decoder)
            .value()
            .map{$0.datas}
            .eraseToAnyPublisher()
        
    }
    
    func fetchMeasurementResult(_ id: Int) -> AnyPublisher<MeasurementResult, some Error>{
        return vitalWinkAPI.request(MeasurementRouter.fetchMeasurementResult(id))
            .validate(statusCode: 200...200)
            .publishDecodable(type: MeasurementResult.self)
            .value()
            .eraseToAnyPublisher()
    }
    @Dependency(\.vitalWinkAPI) private var vitalWinkAPI
}

extension MeasurmentAPI: DependencyKey{
    static var liveValue: MeasurmentAPI = MeasurmentAPI()
    static var testValue: MeasurmentAPI = MeasurmentAPI()
}
