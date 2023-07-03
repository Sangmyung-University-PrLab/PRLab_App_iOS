//
//  MetricChart.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/03.
//

import Foundation
import ComposableArchitecture

struct MetricChart: ReducerProtocol{
    struct State: Equatable{
        @BindingState var period: Period = .week
        var datas: [MetricData<MinMaxType<Float>>]{
            get{
                return _datas.reversed()
            }
        }
    
        fileprivate var _datas: [MetricData<MinMaxType<Float>>] = []
        fileprivate(set) var selected: Int? = nil
        fileprivate(set) var baseRange: MinMaxType<Float> = .init(min: 0, max: 0)
    }
    
    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case fetchMetricDatas(Metric, Date)
        case responseMetricDatas([MetricData<MinMaxType<Float>>])
        case selectItem(_ index: Int?)
        case errorHandling(Error)
    }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce{state, action in
            switch action{
            case .binding:
                return .none
            case .selectItem(let index):
                state.selected = index
                return .none
                
            case .fetchMetricDatas(let metric, let date):
                return .run{[period = state.period]send in
                    switch await fetchMetricData(metric: metric, period: period, basisDate: date){
                    case .success(let datas):
                        await send(.responseMetricDatas(datas))
                    case .failure(let error):
                        await send(.errorHandling(error))
                    }
                }
       
            case .responseMetricDatas(let datas):
                state.baseRange = datas.map{$0.value}
                    .reduce(MinMaxType(min: datas.first?.value.min ?? 0, max: datas.first?.value.max ?? 0)){
                    let min = $0.min < $1.min ? $0.min : $1.min
                    let max = $0.max > $1.max ? $0.max : $1.max
                    
                    return MinMaxType(min: min, max: max)
                }
                state._datas = datas
                return .none
         
            case .errorHandling(let error):
                print(error.localizedDescription)
                return .none
            }
        }
    }

    private func fetchMetricData(metric: Metric, period: Period, basisDate: Date) async -> Result<[MetricData<MinMaxType<Float>>], Error> {
        switch await monitoringAPI.fetchMetricDatas(metric, period: period, basisDate: basisDate, valueType: MinMaxType<Float>.self){
        case .success(let datas):
            return .success(datas)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    @Dependency(\.montioringAPI) private var monitoringAPI
}
