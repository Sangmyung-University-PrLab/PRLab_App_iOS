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
            return datas.keys.sorted(by: >)
        }
        
        @BindingState var period: Period = .week
        fileprivate var basisDate: Date? = nil
        fileprivate(set) var datas: [String : ChartData?] = [:]
        fileprivate(set) var xs: [String: String] = [:]
        fileprivate(set) var selected: String? = nil
        fileprivate(set) var baseRange: MinMaxType<Float>? = nil
        fileprivate(set) var isScrollViewAligned = false
    
    }
    
    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case fetchMetricDatas(_ metric: Metric, _ dateString: String? = nil)
        case responseMetricDatas([MetricData<MinMaxType<Float>>])
        case selectItem(_ index: String?)
        case errorHandling(Error)
        case changeVisible(String,Bool)
        case setBaseRange
        case scrollViewAligned
    }
    enum CancelId: Hashable{
        case setBaseRange
    }
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce{state, action in
            switch action{
            case .scrollViewAligned:
                state.isScrollViewAligned = true
                return .none
            case .changeVisible(let key,let isVisible):
                guard var data = state.datas[key, default: nil] else{
                    return .none
                }
                data.isVisible = isVisible
                state.datas[key] = data
                
                return
                    .cancel(id:CancelId.setBaseRange)
                    .merge(with: .run{send in
                        print("sleep start")
                        do{
                            try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * 1))
                        }catch{
                            await send(.errorHandling(error))
                        }
                        print("sleep end")
                    }.cancellable(id: CancelId.setBaseRange, cancelInFlight: true))
                    .concatenate(with: .send(.setBaseRange, animation:.linear).cancellable(id: CancelId.setBaseRange, cancelInFlight: true))
                
            case .setBaseRange:
                let visibleDatas = state.datas
                    .compactMapValues{$0}
                    .filter{$0.value.isVisible}
                    .map{$0.value.value}
                print(visibleDatas)
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
            case .selectItem(let key):
                state.selected = key
                return .none
            
            case .fetchMetricDatas(let metric, let dateString):
                let date = dateString == nil ? .now : dateFormatter.date(from: dateString!)!
                var prevMonth = Calendar.current.component(.month, from: date)
//                var prevYear = Calendar.current.component(.year, from: date)
                var dateArray: [Date] = []
                
                switch state.period{
                case .day:
                    break
                case .week:
                    dateArray = date.dateArrayInPeriod()
                case .month:
                    dateArray = date.dateArrayInPeriod(period: .month)
                case .year:
                    dateArray = date.dateArrayInPeriod(period: .year)
                }
             
                dateArray.forEach{
                    let dateString = dateFormatter.string(from: $0)
                    let yyyyMMdd = dateString.split(separator: "/").map{Int($0)!}
                    state.datas.updateValue(nil, forKey: dateString)
                    
                    switch state.period{
                    case .day:
                        break
                    case .week:
                        let x = yyyyMMdd[2] == 1 ? "\(yyyyMMdd[1])/\(yyyyMMdd[2])" : "\(yyyyMMdd[2])"
                        state.xs.updateValue(x, forKey: dateString)
                    case .month:
                        let month = yyyyMMdd[1]
                        let x = month != prevMonth ? "\(yyyyMMdd[1])/\(yyyyMMdd[2])" : "\(yyyyMMdd[2])"
                        prevMonth = month
                        state.xs.updateValue(x, forKey: dateString)
                    case .year:
                        let year = yyyyMMdd[0]
                        let x = "\(yyyyMMdd[1])"
//                        prevYear = year
                        state.xs.updateValue(x, forKey: dateString)
                    }
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
                if state.baseRange == nil {
                    state.datas.compactMapValues{$0}.forEach{
                        var data = $0.value
                        data.isVisible = true
                        state.datas[$0.key] = data
                    }
                    return .send(.setBaseRange)
                }
                else{
                    return .none
                }
                
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
