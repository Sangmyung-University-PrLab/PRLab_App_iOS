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
        var sortedKeys: [String]{
            return datas.keys.sorted(by: >)
        }
        
        @BindingState var period: Period = .week
        fileprivate(set) var datas: [String : ChartData?] = [:]
        fileprivate(set) var xs: [String: String] = [:]
        fileprivate(set) var selected: String? = nil
        fileprivate(set) var baseRange: MinMaxType<Float>? = nil
        fileprivate var isBaseRangeInited = false
    }
    
    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case fetchMetricDatas(_ metric: Metric, _ dateString: String? = nil)
        case responseMetricDatas([MetricData<MinMaxType<Float>>])
        case selectItem(_ key: String)
        case errorHandling(Error)
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
                    .merge(with: .run{send in
                 
                        do{
                            try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * 1))
                        }catch{
                            await send(.errorHandling(error))
                        }
                       
                    }.cancellable(id: CancelId.setBaseRange, cancelInFlight: true))
                    .concatenate(with: .send(.setBaseRange, animation:.linear).cancellable(id: CancelId.setBaseRange, cancelInFlight: true))
                
            case .setBaseRange:
                let visibleDatas = !state.isBaseRangeInited ? state
                    .sortedKeys[0 ..< state.period.numberOfItem]
                    .compactMap{state.datas[$0, default: nil]}
                    .map{$0.value} : state.datas
                    .compactMapValues{$0}
                    .filter{$0.value.isVisible}
                    .map{$0.value.value}
                state.isBaseRangeInited = true
                
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
                state.isBaseRangeInited = false
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
                
                    state.datas.updateValue(state.datas[dateString, default:nil], forKey: dateString)
                    
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
                        state.xs.updateValue(x, forKey: dateString)
                    }
                }
                
                return .run{[period = state.period]send in
                    switch metric{
                    case .expressionAnalysis:
                        switch await fetchExpressionAnalysisData(period: period, basisDate: date){
                        case .success(let datas):
                            await send(.responseMetricDatas([]))
                        case .failure(let error):
                            await send(.errorHandling(error))
                        }
                    default:
                        switch await fetchMetricData(metric: metric, period: period, basisDate: date){
                        case .success(let datas):
                            await send(.responseMetricDatas(datas))
                        case .failure(let error):
                            await send(.errorHandling(error))
                        }
                    }
                   
                }
       
            case .responseMetricDatas(let datas):
                datas.forEach{
                    state.datas[dateFormatter.string(from: $0.basisDate)] = .init(value: $0.value,isVisible:false)
                }

                return state.isBaseRangeInited ? .none : .send(.setBaseRange)
                
                
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
    
    private func fetchExpressionAnalysisData(period: Period, basisDate: Date) async -> Result<[MetricData<ExpressionAnalysisMetricValue>], Error> {
        switch await monitoringAPI.fetchMetricDatas(.expressionAnalysis, period: period, basisDate: basisDate, valueType: ExpressionAnalysisMetricValue.self){
        case .success(let data):
            print(data)
            return .success([])
        case .failure(let error):
            return .failure(error)
        }
    }
    
    
    private var dateFormatter = DateFormatter()
    @Dependency(\.montioringAPI) private var monitoringAPI
}
