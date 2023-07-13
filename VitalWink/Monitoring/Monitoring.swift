//
//  Monitoring.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/28.
//

import Foundation
import ComposableArchitecture
import OSLog
struct Monitoring: ReducerProtocol{
    struct State: Equatable{
        fileprivate(set) var recentData: RecentData? = nil
        fileprivate(set) var metricChart: MetricChart.State = .init()
        fileprivate(set) var alertState: VitalWinkAlertMessageState<Action>? = nil
    }
    
    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case fetchRecentData
        case responseRecentData(RecentData)
        case metricChart(MetricChart.Action)
        case errorHandling(Error)
        
    }
    
    var body: some ReducerProtocol<State, Action>{
        BindingReducer()
        Reduce{state, action in
            switch action{
            case .binding:
                return .none
            case .metricChart:
                return .none
            case .fetchRecentData:
                return .run{send in
                    switch await monitoringAPI.fetchRecentData(){
                    case .success(let data):
                        await send(.responseRecentData(data))
                    case .failure(let error):
                        await send(.errorHandling(error))
                    }
                }
       
            case .responseRecentData(let data):
                state.recentData = data
                return .none
            case .errorHandling(let error):
                state.alertState = .init(title: "기록", message: "기록 조회 중 오류가 발생했습니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                let message = error.localizedDescription
                os_log(.error, log:.monitoring,"%@", message)
                
                return .none
            }
        }
        Scope(state: \.metricChart, action: /Action.metricChart){
            MetricChart()
        }
    }
    
    
    func fetchIntMetricData(metric: Metric, period: Period, basisDate: Date) async -> Result<[MetricData<MinMaxType<Int>>], Error> {
        switch await monitoringAPI.fetchMetricDatas(metric, period: period, basisDate: basisDate, valueType: MinMaxType<Int>.self){
        case .success(let datas):
            return .success(datas)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    @Dependency(\.montioringAPI) private var monitoringAPI
}
