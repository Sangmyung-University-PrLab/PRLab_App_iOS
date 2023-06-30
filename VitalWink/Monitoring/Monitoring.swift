//
//  Monitoring.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/28.
//

import Foundation
import ComposableArchitecture

struct Monitoring: ReducerProtocol{
    struct State: Equatable{
        @BindingState var period: MonitoringRouter.Period = .week
        
        fileprivate(set) var recentData: RecentData? = nil
        fileprivate(set) var intMetricDatas: [MetricData<MinMaxType<Int>>] = []
    }
    
    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case fetchRecentData
        case fetchMetricDatas(MonitoringRouter.Metric, Date)
        case responseRecentData(RecentData)
        case responseIntMetricDatas([MetricData<MinMaxType<Int>>])
        case errorHandling(Error)
        
    }
    
    var body: some ReducerProtocol<State, Action>{
        BindingReducer()
        Reduce{state, action in
            switch action{
            case .binding:
                return .none
            case .fetchMetricDatas(let metric, let date):
                return .run{[period = state.period]send in
                    switch await fetchIntMetricData(metric: metric, period: period, basisDate: date){
                    case .success(let datas):
                        await send(.responseIntMetricDatas(datas))
                    case .failure(let error):
                        await send(.errorHandling(error))
                    }
                }
            case .fetchRecentData:
                return .run{send in
                    switch await monitoringAPI.fetchRecentData(){
                    case .success(let data):
                        await send(.responseRecentData(data))
                    case .failure(let error):
                        await send(.errorHandling(error))
                    }
                }
            case .responseIntMetricDatas(let datas):
                state.intMetricDatas = datas
                return .none
            case .responseRecentData(let data):
                state.recentData = data
                return .none
            case .errorHandling(let error):
                print(error.localizedDescription)
                return .none
            }
        }
    }
    
    
    func fetchIntMetricData(metric: MonitoringRouter.Metric, period: MonitoringRouter.Period, basisDate: Date) async -> Result<[MetricData<MinMaxType<Int>>], Error> {
        switch await monitoringAPI.fetchMetricDatas(metric, period: period, basisDate: basisDate, valueType: MinMaxType<Int>.self){
        case .success(let datas):
            return .success(datas)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    @Dependency(\.montioringAPI) private var monitoringAPI
}
