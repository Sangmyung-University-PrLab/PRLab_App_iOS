//
//  ASAuthorizationControllerDelgateImpl.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/20.
//

import Foundation
import AuthenticationServices

final class ASAuthorizationControllerDelgateImpl: NSObject, ASAuthorizationControllerDelegate, Sendable{
    let loginStream: AsyncStream<String?>
    override init() {
        var continuation: AsyncStream<String?>.Continuation!
        loginStream = AsyncStream{
            continuation = $0
        }
        self.continuation = continuation
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else{
            continuation.yield(nil)
            return
        }
        
        guard let token = credential.identityToken else{
            continuation.yield(nil)
            return
        }
        
        UserDefaults.standard.setValue(credential.email, forKey: "apple_email")
        continuation.yield(String(data: token, encoding: .utf8)!)
    }
    
    private let continuation: AsyncStream<String?>.Continuation
}
