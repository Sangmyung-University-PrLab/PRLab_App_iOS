//
//  MetricChart.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/03.
//

import Foundation
import ComposableArchitecture

struct MetricChart: ReducerProtocol{
    init(){
        dateFormatter.dateFormat = "yyyy/MM/dd"
    }
    struct State: Equatable{
        @BindingState var period: Period = .week
        fileprivate var basisDate: Date? = nil
        fileprivate(set) var datas: [String : MinMaxType<Float>?] = [:]
        fileprivate(set) var selected: Int? = nil
        fileprivate(set) var baseRange: MinMaxType<Float> = .init(min: 0, max: 0)
    }
    
    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case fetchMetricDatas(Metric, Date)
        case responseMetricDatas([MetricData<MinMaxType<Float>>])
        case selectItem(_ index: Int?)
        case errorHandling(Error)
        case refresh(Metric)
    }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce{state, action in
            switch action{
            case .binding(\.$period):
                state.datas = [:]
                state.basisDate = nil
                state.selected = nil
                
                if state.period == .day{
                    dateFormatter.dateFormat = "MM:dd"
                }
                else{
                    dateFormatter.dateFormat = "yyyy/MM/dd"
                }
                
                return .none
            case .binding:
                return .none
            case .selectItem(let index):
                state.selected = index
                return .none
            case .refresh(let metric):
                if state.datas.keys.isEmpty{
                    return .none
                }
                let earliestDate = state.datas.keys.sorted().first!
                let date = Date(timeInterval: -60 * 60 * 24 * 1, since: dateFormatter.date(from: earliestDate)!)
              
                return .send(.fetchMetricDatas(metric, date))
                    
            case .fetchMetricDatas(let metric, let date):
                if state.basisDate == nil{
                    state.basisDate = date
                }
                
                let dateArray = date.dateArrayInPeriod(end: Date(timeInterval: -60 * 60 * 24 * 7 * 2, since: date))
                dateArray.forEach{
                    state.datas.updateValue(nil, forKey: dateFormatter.string(from: $0))
                }

                return .run{[period = state.period]send in
                    switch await fetchMetricData(metric: metric, period: period, basisDate: date){
                    case .success(let datas):
                        await send(.responseMetricDatas(datas))
                    case .failure(let error):
                        await send(.errorHandling(error))
                    }
                }
       
            case .responseMetricDatas(let datas):
                datas.forEach{
                    state.datas[dateFormatter.string(from: $0.basisDate)] = $0.value
                }
//                print(state.datas)
                state.baseRange = state.datas.compactMapValues{$0}.map{$0.value}
                    .reduce(MinMaxType(min: datas.first?.value.min ?? 0, max: datas.first?.value.max ?? 0)){
                    let min = $0.min < $1.min ? $0.min : $1.min
                    let max = $0.max > $1.max ? $0.max : $1.max

                    return MinMaxType(min: min, max: max)
                }
                
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
    
    private var dateFormatter = DateFormatter()
    @Dependency(\.montioringAPI) private var monitoringAPI
}
