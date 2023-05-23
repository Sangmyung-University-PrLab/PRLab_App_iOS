//
//  Router.swift
//


import Alamofire
import Dependencies

final class VitalWinkAPI{
    init(isTest: Bool = false){
        if isTest{
            let config = URLSessionConfiguration.af.ephemeral
            config.protocolClasses = [MockMeasurmentProtocol.self, MockUserProtocol.self]
            session = Session(configuration: config)
            
        }
        else{
            session = Session()
        }
    }
    
    func request<Router: VitalWinkRouterType>(_ router: Router, requireToken: Bool = true) -> DataRequest{
        return session.request(VitalWinkRouter(router), interceptor: requireToken ? authInterceptor : nil)
    }
    
    func upload<Router: VitalWinkUploadableRouterType>(_ router: Router) -> DataRequest{
        return session
            .upload(multipartFormData: router.multipartFormData, with: VitalWinkRouter(router))
    }
    
    
    
    private let authInterceptor = AuthInterceptor()
    private let session: Session
}

extension VitalWinkAPI: DependencyKey{
    static var liveValue: VitalWinkAPI = VitalWinkAPI()
    static var testValue: VitalWinkAPI = VitalWinkAPI(isTest: true)
}
