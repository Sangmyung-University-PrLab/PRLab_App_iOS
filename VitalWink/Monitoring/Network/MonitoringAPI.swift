//
//  MonitoringAPI.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/28.
//
import SwiftyJSON
import Foundation
import Alamofire
import Dependencies
import Combine
final class MonitoringAPI{
    func fetchRecentData() async -> Result<RecentData, Error>{
        return await withCheckedContinuation{continuation in
            vitalWinkAPI.request(MonitoringRouter.fetchRecentData)
                .validate(statusCode: 200 ..< 300)
                .responseDecodable(of: RecentData.self){
                    switch $0.result{
                    case .success(let data):
                        continuation.resume(returning: .success(data))
                    case .failure(let error):
                        continuation.resume(returning: .failure(error))
                    }
                }
               
        }
    }
    
    func fetchMetricDatas<ValueType>(_ metric: MonitoringRouter.Metric, period: MonitoringRouter.Period, basisDate: Date, valueType: ValueType.Type = ValueType.self) async -> Result<[MetricData<ValueType>], Error> where ValueType: Codable{

        return await withCheckedContinuation{continuation in
            vitalWinkAPI.request(MonitoringRouter.fetchMetricDatas(metric, period: period, basisDate: basisDate))
                .validate(statusCode: 200 ..< 300)
                .responseDecodable(of: MetricDataResponse<ValueType>.self){
                    switch $0.result{
                    case .success(let data):
                        continuation.resume(returning: .success(data.datas))
                    case .failure(let error):
                        continuation.resume(returning: .failure(error))
                    }
                }
                
                
        }
        
        
        
            
        
    }
    
    @Dependency(\.vitalWinkAPI) private var vitalWinkAPI
}

extension MonitoringAPI: DependencyKey{
    static var liveValue: MonitoringAPI = MonitoringAPI()
}
