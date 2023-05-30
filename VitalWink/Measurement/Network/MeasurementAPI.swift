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
    func signalMeasurment(bgrValues: [(Int, Int, Int)], type: Measurement.Target) -> AnyPublisher<Int, Error>{
        return Future<Int, Error>{[weak self] promise in
            guard let strongSelf = self else{
                return
            }
            
            strongSelf.vitalWinkAPI.request(MeasurementRouter.signalMeasurement(bgrValues: bgrValues, target: type))
                .validate(statusCode: 201...201)
                .responseDecodable(of: JSON.self){
                    switch $0.result{
                    case .success(let json):
                        let id = json["measurement_id"]
                        
                        guard id.error == nil else{
                            promise(.failure(id.error!))
                            return
                        }
                        
                        promise(.success(id.intValue))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    func expressionAndBMI(image: UIImage, id: Int) -> AnyPublisher<Never,some Error>{
        return vitalWinkAPI.upload(MeasurementRouter.expressionAndBMIMeasurement(image: image, id: id))
            .validate(statusCode: 201 ... 201)
            .publishUnserialized()
            .value()
            .ignoreOutput()
            .eraseToAnyPublisher()
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
