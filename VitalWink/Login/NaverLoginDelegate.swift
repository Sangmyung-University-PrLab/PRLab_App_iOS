//
//  NaverLoginDelegate.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/26.
//
import Alamofire
import Foundation
import NaverThirdPartyLogin
import OSLog
import SwiftyJSON

final class NaverLoginDelegate: NSObject,NaverThirdPartyLoginConnectionDelegate, Sendable{
    let loginStream: AsyncThrowingStream<Void, Error>
    override init() {
        var continuation: AsyncThrowingStream<Void, Error>.Continuation!
        loginStream = AsyncThrowingStream{
            continuation = $0
        }
        self.continuation = continuation
    }
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        continuation.yield()

        return
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        continuation.yield()
        return
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        return
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        let message = error.localizedDescription
        os_log(.error, log: .login, "%@", message)
        continuation.finish(throwing: error)
    }
    
    private let continuation: AsyncThrowingStream<Void, Error>.Continuation
}
