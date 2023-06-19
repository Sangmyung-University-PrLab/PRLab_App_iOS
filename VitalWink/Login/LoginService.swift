//
//  LoginService.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/16.
//

import Foundation
import KakaoSDKUser
import GoogleSignIn
import KakaoSDKAuth
import Dependencies
import NaverThirdPartyLogin

final class LoginService: Sendable{
    init(){
        guard let info = Bundle.main.infoDictionary else{
            fatalError("Info.plist가 없습니다.")
        }
        
        guard let clientId = info["GOOGLE_CLIENT_ID"] as? String else{
            fatalError("구글 로그인을 위한 클라이언트 아이디가 존재하지 않습니다.")
        }
        
        gidConfig = GIDConfiguration(clientID: clientId)
        NaverThirdPartyLoginConnection.getSharedInstance().resetToken()
        NaverThirdPartyLoginConnection.getSharedInstance().delegate = naverLoginDelgate
    }
    enum Status{
        case success(_ token: String)
        case shouldSignUp
        case notFoundUser
        case inconsistentInformation
    }
    enum LoginServiceError: LocalizedError{
        case notHaveAccessToken
        case failGetRootViewController
        
        var errorDescription: String?{
            switch self{
            case .failGetRootViewController:
                return "root viewContorller를 가져오는데 실패했습니다."
            case .notHaveAccessToken:
                return "access token을 가져오는데 실패했습니다."
            }
        }
    }
    
    func snsLogin(_ type: UserModel.`Type`) async -> Result<Status, Error>{
        switch type{
        case .kakao:
            return await kakaoLogin()
        case .google:
            return await googleLogin()
        case .apple:
            return await kakaoLogin()
        case .naver:
            return await naverLogin()
        default:
            fatalError("지원하지 않는 유저 타입입니다.")
        }
    }
    
    func generalLogin(id: String, password: String) async -> Result<Status, Error>{
        switch await loginAPI.generalLogin(id: id, password: password){
        case .success(let token):
            return .success(.success(token))
        case .failure(let error):
            guard let afError = error.asAFError else{
                return .failure(error)
            }
            
            guard afError.isResponseValidationError, let statusCode = afError.responseCode else{
                return .failure(afError)
            }
            
            if statusCode == 404{
                return .success(.notFoundUser)
            }
            else if statusCode == 409{
                return .success(.inconsistentInformation)
            }
            else{
                return .failure(afError)
            }
        }
    }
    
    //MARK: private
    private func googleLogin() async -> Result<Status, Error>{
        guard let rootContoller = await UIApplication.shared.rootController else{
            return .failure(LoginServiceError.failGetRootViewController)
        }
        
        return await withCheckedContinuation{continuation in   
            DispatchQueue.main.async {[weak self] in
                guard let strongSelf = self else{
                    return
                }
                
                GIDSignIn.sharedInstance.signIn(with: strongSelf.gidConfig, presenting: rootContoller){
                    guard $1 == nil else{
                        continuation.resume(returning: .failure($1!))
                        return
                    }
                    
                    guard let credential = $0, let token = credential.authentication.idToken else{
                        continuation.resume(returning: .failure(LoginServiceError.notHaveAccessToken))
                        return
                    }
                    
                    Task{
                        await strongSelf.tokenHandling(type: .google, token: token, continuation: continuation)
                    }
                    
                }
            }
        }
    }
    
    private func kakaoLogin() async -> Result<Status, Error>{
        return await withCheckedContinuation{continuation in
            let completion: (OAuthToken?, Error?) -> Void = {token, error in
                guard error == nil else{
                    continuation.resume(returning: .failure(error!))
                    return
                }
                guard let token = token?.accessToken else{
                    continuation.resume(returning: .failure(LoginServiceError.notHaveAccessToken))
                    return
                }
                
                Task{[weak self] in
                    guard let strongSelf = self else{
                        return
                    }
                    await strongSelf.tokenHandling(type: .kakao, token: token, continuation: continuation)
                }
            }
            
            if UserApi.isKakaoTalkLoginAvailable(){
                UserApi.shared.loginWithKakaoTalk(completion: completion)
            }
            else{
                DispatchQueue.main.async {
                    UserApi.shared.loginWithKakaoAccount(completion: completion)
                }
                
            }
        }
    }
  
    private func naverLogin() async -> Result<Status, Error>{
         await NaverThirdPartyLoginConnection
            .getSharedInstance()
            .requestThirdPartyLogin()
        
        return await withCheckedContinuation{continuation in
            Task{
                for await _ in naverLoginDelgate.loginStream{
                    guard let token = await NaverThirdPartyLoginConnection.getSharedInstance().accessToken else{
                        continuation.resume(returning: .failure(LoginServiceError.notHaveAccessToken))
                        return
                    }
                    await tokenHandling(type: .naver, token: token, continuation: continuation)
                    break
                }
            }
        }
    }

    
    
    private func tokenHandling(type: UserModel.`Type`, token: String, continuation: CheckedContinuation<Result<LoginService.Status, Error>, Never>) async{
        switch await loginAPI.snsLogin(type: type, token: token){
        case .success(let token):
            continuation.resume(returning: .success(.success(token)))
        case .failure(let error):
            guard let afError = error.asAFError else{
                continuation.resume(returning:.failure(error))
                return
            }
            
            guard afError.isResponseValidationError, let statusCode = afError.responseCode else{
                continuation.resume(returning:.failure(afError))
                return
            }
            
           statusCode == 404 ? continuation.resume(returning:.success(.shouldSignUp))
            : continuation.resume(returning: .failure(afError))
        }
    }
    
    
    private let gidConfig: GIDConfiguration
    private let naverLoginDelgate = NaverLoginDelegate()
    @Dependency(\.loginAPI) private var loginAPI
}
