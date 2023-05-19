//
//  Router.swift
//


import Alamofire
import Dependencies

final class VitalWinkAPI{
    init(isTest: Bool = false){
        if isTest{
            let config = URLSessionConfiguration.af.ephemeral
            config.protocolClasses = [MockUserProtocol.self]
            session = Session(configuration: config)
            
        }
        else{
            session = Session()
        }
    }
    
    func request<Router: VitalWinkRouterType>(_ router: Router, requireToken: Bool = true) -> DataRequest{
        return session.request(VitalWinkRouter(router), interceptor: requireToken ? authInterceptor : nil)
    }
    
    private let authInterceptor = AuthInterceptor()
    private let session: Session
}

extension VitalWinkAPI: DependencyKey{
    static var liveValue: VitalWinkAPI = VitalWinkAPI()
    static var testValue: VitalWinkAPI = VitalWinkAPI(isTest: true)
}
