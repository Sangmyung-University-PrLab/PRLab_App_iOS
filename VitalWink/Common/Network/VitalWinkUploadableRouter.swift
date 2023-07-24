//
//  VitalWinkUploadableRouter.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/21.
//

import Foundation
import Alamofire

protocol VitalWinkUploadableRouterType: VitalWinkRouterType{
    func multipartFormData(_ formData: MultipartFormData)
}
