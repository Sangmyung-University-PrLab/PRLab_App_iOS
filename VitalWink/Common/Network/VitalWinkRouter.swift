//
//  VitalWinkRouter.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/18.
//

import Foundation
import Alamofire
protocol VitalWinkRouterType{
    var endPoint: String{get}
    var method: HTTPMethod{get}
    var parameters: Parameters{get}
    var queries: [URLQueryItem]{get}
}

struct VitalWinkRouter<Router: VitalWinkRouterType>: URLRequestConvertible{
    init(_ router: Router){
        self.router = router
    }
    
    func asURLRequest() throws -> URLRequest {
        var component = URLComponents(string: router.endPoint)!
        component.queryItems = router.queries
        let url = component.url(relativeTo: URL(string: baseURL))!
        var request = URLRequest(url: url)
        
        if !router.parameters.isEmpty{
            request.httpBody = try JSONEncoding.default.encode(request, with: router.parameters).httpBody
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.method = router.method
        return request
    }
    //MARK: private
    private let router: Router
    private var baseURL: String{
        guard let info = Bundle.main.infoDictionary else{
            return ""
        }
        return info["BASE_URL"] as? String ?? ""
    }
}
