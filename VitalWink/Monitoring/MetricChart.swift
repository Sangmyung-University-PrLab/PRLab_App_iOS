//
//  MetricChart.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/03.
//

import Foundation
import OSLog
@preconcurrency import ComposableArchitecture

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
        fileprivate(set) var isLoading = false
        fileprivate(set) var datas: [String : [ChartData]] = [:]
        fileprivate(set) var expressions: [String: [Expression: Float]] = [:]
        fileprivate(set) var xs: [String: String] = [:]
        fileprivate(set) var selected: String? = nil
        fileprivate(set) var baseRange: MinMaxType<Float>? = nil
        fileprivate var isBaseRangeInited = false
        fileprivate(set) var alertState: VitalWinkAlertMessageState<Action>? = nil
    }
    
    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case fetchMetricDatas(_ metric: Metric, _ dateString: String? = nil)
        case responseMetricDatas([MetricData<MinMaxType<Float>>])
        case responseExpressionAnalysisDatas([MetricData<ExpressionAnalysisMetricValue>])
        case responseBloodPressureDatas([MetricData<BloodPressureMetricValue>])
        case selectItem(_ key: String)
        case errorHandling(Error)
        case changeVisible(String,Bool)
        case setBaseRange
        case reset
        case onDisappear
        case alertDismiss
    }
    enum CancelId: Hashable{
        case setBaseRange
    }
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce{state, action in
            switch action{
            case .alertDismiss:
                state.alertState = nil
                return .none
            case .changeVisible(let key,let isVisible):
                var data = state.datas[key, default: []]
                guard !data.isEmpty else{
                    return .none
                }
                
                data.enumerated().forEach{
                    let index = $0.offset
                    var element = $0.element
                    
                    element.isVisible = isVisible
                    data[index] = element
                }
                state.datas[key] = data

                return
                    .cancel(id:CancelId.setBaseRange)
                    .merge(with: .run{send in
                        do{
                            try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * 0.5))
                        }catch{
                            await send(.errorHandling(error))
                        }
                        await send(.setBaseRange, animation:.linear)
                    }.cancellable(id: CancelId.setBaseRange, cancelInFlight: true))
                    
                
            case .setBaseRange:
                let visibleDatas = !state.isBaseRangeInited ? state
                    .sortedKeys[0 ..< state.period.numberOfItem]
                    .flatMap{state.datas[$0, default: []]}
                    .map{$0.value} : state.datas
                    .values.flatMap{$0}
                    .filter{$0.isVisible}
                    .map{$0.value}
                
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

                return .none
                
            case .binding(\.$period):
//                if state.period == .day{
//                    dateFormatter.dateFormat = "MM:dd"
//                }
//                else{
                    dateFormatter.dateFormat = "yyyy/MM/dd"
//                }
                
                return .send(.reset)
            case .binding:
                return .none
            case .selectItem(let key):
                state.selected = key
                return .none
            
            case .fetchMetricDatas(let metric, let dateString):
                state.isLoading = true
               
                let date = dateString == nil ? .now : dateFormatter.date(from: dateString!)!
                var prevMonth = Calendar.current.component(.month, from: date)
                var dateArray: [Date] = []
                
                switch state.period{
//                case .day:
//                    break
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
                
                    state.datas.updateValue(state.datas[dateString, default:[]], forKey: dateString)
                    
                    switch state.period{
//                    case .day:
//                        break
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
                        switch await fetchExpressionAnalysisDatas(period: period, basisDate: date){
                        case .success(let datas):
                            await send(.responseExpressionAnalysisDatas(datas))
                        case .failure(let error):
                            await send(.errorHandling(error))
                        }
                    case .bloodPressure:
                        switch await fetchBloodPressureDatas(period: period, basisDate: date){
                        case .success(let datas):
                            await send(.responseBloodPressureDatas(datas))
                        case .failure(let error):
                            await send(.errorHandling(error))
                        }
                    default:
                        switch await fetchMetricDatas(metric: metric, period: period, basisDate: date){
                        case .success(let datas):
                            await send(.responseMetricDatas(datas))
                        case .failure(let error):
                            await send(.errorHandling(error))
                        }
                    }
                   
                }
       
            case .responseMetricDatas(let datas):
                state.isLoading = false
                
                datas.forEach{
                    state.datas[dateFormatter.string(from: $0.basisDate)] = [.init(value: $0.value,isVisible:false)]
                }
                
                return state.isBaseRangeInited ? .none : .send(.setBaseRange)
                
                
            case .errorHandling(let error):
                state.isLoading = false
                state.alertState = .init(title: "기록", message: "기록 조회 중 오류가 발생했습니다."){
                    VitalWinkAlertButtonState<Action>(title: "확인"){
                        return nil
                    }
                }
                let message = error.localizedDescription
                os_log(.error, log:.metricChart,"%@", message)
                
                return .none
            case .responseExpressionAnalysisDatas(let datas):
                state.isLoading = false
                datas.forEach{
                    let key = dateFormatter.string(from: $0.basisDate)
                    state.datas[key] = [.init(value: $0.value.valence, isVisible:false), .init(value: $0.value.arousal, isVisible:false)]
                    state.expressions[key] = $0.value.expressions
                }
                
                return state.isBaseRangeInited ? .none : .send(.setBaseRange)
            case .responseBloodPressureDatas(let datas):
                state.isLoading = false
                datas.forEach{
                    let key = dateFormatter.string(from: $0.basisDate)
                    state.datas[key] = [.init(value: MinMaxType(min:  Float($0.value.SYS.min), max: Float($0.value.SYS.max)), isVisible:false), .init(value:MinMaxType(min:  Float($0.value.DIA.min), max: Float($0.value.DIA.max)), isVisible:false)]
                }
                
                return state.isBaseRangeInited ? .none : .send(.setBaseRange)
            case .reset:
                state.datas = [:]
                state.isBaseRangeInited = false
                state.selected = nil
                state.baseRange = nil
                state.expressions = [:]
                return .none
                
            case .onDisappear:
                state = State()
                return .cancel(id:CancelId.setBaseRange)
            }
        }
    }

    private func fetchMetricDatas(metric: Metric, period: Period, basisDate: Date) async -> Result<[MetricData<MinMaxType<Float>>], Error> {
        switch await monitoringAPI.fetchMetricDatas(metric, period: period, basisDate: basisDate, valueType: MinMaxType<Float>.self){
        case .success(let datas):
            return .success(datas)
        case .failure(let error):
            return .failure(error)
        }
    }
    private func fetchExpressionAnalysisDatas(period: Period, basisDate: Date) async -> Result<[MetricData<ExpressionAnalysisMetricValue>], Error> {
        switch await monitoringAPI.fetchMetricDatas(.expressionAnalysis, period: period, basisDate: basisDate, valueType: ExpressionAnalysisMetricValue.self){
        case .success(let datas):
            return .success(datas)
        case .failure(let error):
            return .failure(error)
        }
    }
    private func fetchBloodPressureDatas(period: Period, basisDate: Date) async -> Result<[MetricData<BloodPressureMetricValue>], Error> {
        switch await monitoringAPI.fetchMetricDatas(.bloodPressure, period: period, basisDate: basisDate, valueType: BloodPressureMetricValue.self){
        case .success(let datas):
            return .success(datas)
        case .failure(let error):
            return .failure(error)
        }
    }
    private var dateFormatter = DateFormatter()
    @Dependency(\.montioringAPI) private var monitoringAPI
}
