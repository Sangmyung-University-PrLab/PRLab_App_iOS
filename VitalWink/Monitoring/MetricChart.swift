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
    struct ChartData: Equatable{
        let value: MinMaxType<Float>
        var isVisible:Bool
    }
    struct State: Equatable{
//        static func == (lhs: MetricChart.State, rhs: MetricChart.State) -> Bool {
//            return lhs.period == rhs.period && lhs.basisDate == rhs.basisDate && lhs.selected == rhs.selected
//            && lhs.baseRange == rhs.baseRange && lhs.datas.elementsEqual(rhs.datas){
//                return $0.value.isVisable == $1.value.isVisable && $1.value.value == $0.value.value
//            }
//        }
        
        var sortedKeys: [String]{
            return datas.keys.sorted()
        }
        
        @BindingState var period: Period = .week
        fileprivate var basisDate: Date? = nil
        fileprivate(set) var datas: [String : ChartData?] = [:]
        fileprivate(set) var selected: Int? = nil
        fileprivate(set) var baseRange: MinMaxType<Float>? = nil
    
    }
    
    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case fetchMetricDatas(Metric, Date)
        case responseMetricDatas([MetricData<MinMaxType<Float>>])
        case selectItem(_ index: Int?)
        case errorHandling(Error)
        case refresh(Metric)
        case changeVisible(String,Bool)
        case setBaseRange
    }
    enum CancelId: Hashable{
        case setBaseRange
    }
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce{state, action in
            switch action{
            case .changeVisible(let key,let isVisible):
                
                guard var data = state.datas[key, default: nil] else{
                    return .none
                }
                data.isVisible = isVisible
                state.datas[key] = data
                
                return
                    .cancel(id:CancelId.setBaseRange)
                    .merge(with: .run{_ in
                        try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * 0.5))
                    })
                .concatenate(with: .send(.setBaseRange, animation:.linear).cancellable(id: CancelId.setBaseRange, cancelInFlight: true))
                
            case .setBaseRange:
                let visibleDatas = state.datas
                    .compactMapValues{$0}
                    .filter{$0.value.isVisible}
                    .map{$0.value.value}
                
                
                guard !visibleDatas.isEmpty else{
                    state.baseRange = nil
                    return .none
                }
                
                
                state.baseRange = visibleDatas.reduce(MinMaxType(min: visibleDatas.first?.min ?? 0, max: visibleDatas.first?.max ?? 0)){
                    let min = $0.min < $1.min ? $0.min : $1.min
                    let max = $0.max > $1.max ? $0.max : $1.max
                    
                    return MinMaxType(min: min, max: max)
                }
                
                
                
                
                if state.baseRange!.max == 0 && state.baseRange!.min == 0{
                    state.baseRange = nil
                }
                return .none
            case .binding(\.$period):
                state.datas = [:]
                state.basisDate = nil
                state.selected = nil
                state.baseRange = nil
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
                
                let dateArray = date.dateArrayInPeriod(end: Date(timeInterval: -60 * 60 * 24 * 7 * 1, since: date))
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
                    state.datas[dateFormatter.string(from: $0.basisDate)] = .init(value: $0.value,isVisible:false)
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
