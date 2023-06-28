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
        fileprivate(set) var recentData: RecentData? = nil
    }
    
    enum Action{
        case fetchRecentData
        case responseRecentData(RecentData)
        case errorHandling(Error)
    }
    
    var body: some ReducerProtocol<State, Action>{
        Reduce{state, action in
            switch action{
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
                print(error.localizedDescription)
                return .none
            }
        }
    }
    
    @Dependency(\.montioringAPI) private var monitoringAPI
}
