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
        NaverThirdPartyLoginConnection.getSharedInstance().delegate = naverLoginDelgate
    }
    enum Status{
        case success(_ token: String)
        case needSignUp
        case notFoundUser
        case inconsistentInformation
    }
    
    
    func snsLogin(_ type: UserModel.`Type`) async -> Result<Status, Error>{
        switch type{
        case .kakao:
            return await kakaoLogin()
        case .google:
            return await kakaoLogin()
        case .apple:
            return await kakaoLogin()
        case .naver:
            return await kakaoLogin()
        default:
            fatalError("지원하지 않는 유저 타입입니다.")
        }
    }
    func getSnsUserInfo(_ type: UserModel.`Type`) async -> Result<UserModel, Error>{
        switch type{
        case .kakao:
            return await getKakaoUserInfo()
        case .google:
            break
        case .apple:
            break
        case .naver:
            break
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
    private func googleLogin(){
        guard let rootContoller = UIApplication.shared.rootController else{
            return
        }
        
        GIDSignIn.sharedInstance.signIn(with: gidConfig, presenting: rootContoller){
            guard $1 == nil else{
                print($1!.localizedDescription)
                return
            }
            
            guard let credential = $0 else{
                print("credential이 nil입니다.")
                return
            }
            print(credential.profile?.email)
        }
    }
    private func kakaoLogin() async -> Result<Status, Error>{
        return await withCheckedContinuation{continuation in
            let completion: (OAuthToken?, Error?) -> Void = {token, error in
                guard error == nil else{
                    continuation.resume(returning: .failure(error!))
                    return
                }
                guard let accessToken = token?.accessToken else{
                    continuation.resume(returning: .failure(error!))
                    return
                }
                
                Task{[weak self] in
                    guard let strongSelf = self else{
                        return
                    }
                    
                    switch await strongSelf.loginAPI.snsLogin(type:.kakao, token: accessToken){
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
  
    private func naverLogin(){
        NaverThirdPartyLoginConnection.getSharedInstance().requestThirdPartyLogin()
    }

    
    private let gidConfig: GIDConfiguration
    private let naverLoginDelgate = NaverLoginDelegate()
    @Dependency(\.loginAPI) private var loginAPI
   
}
