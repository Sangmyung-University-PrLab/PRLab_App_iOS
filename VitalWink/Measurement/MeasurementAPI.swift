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
    func signalMeasurment(frames: [[[UInt8]]], type: MeasurmentRouter.Target) -> AnyPublisher<Int, Error>{
        return Future<Int, Error>{[weak self] promise in
            guard let strongSelf = self else{
                return
            }
            
            strongSelf.vitalWinkAPI.request(MeasurmentRouter.signalMeasurement(frames: frames, target: type))
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
        return vitalWinkAPI.upload(MeasurmentRouter.expressionAndBMIMeasurement(image: image, id: id))
            .validate(statusCode: 201 ... 201)
            .publishUnserialized()
            .value()
            .ignoreOutput()
            .eraseToAnyPublisher()
    }
    
    @Dependency(\.vitalWinkAPI) private var vitalWinkAPI
}

extension MeasurmentAPI: DependencyKey{
    static var liveValue: MeasurmentAPI = MeasurmentAPI()
    static var testValue: MeasurmentAPI = MeasurmentAPI()
}
