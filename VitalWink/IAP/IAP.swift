//
//  IAP.swift
//  VitalWink
//
//  Created by 유호준 on 2023/08/17.
//

import ComposableArchitecture
import StoreKit
class IAP:ReducerProtocol{
    init(){
        self.transactionListener =  Task.detached{
            for await result in Transaction.updates{
                guard let transaction =  await self.handle(result: result) else{
                    return
                }
                
                await transaction.finish()
            }
        }
    }
    deinit{
        self.transactionListener?.cancel()
    }
    struct State: Equatable{
        fileprivate(set) var isSubscribed = false
    }
    enum Action{
        case subscribe
        case getProducts
        case setIsSubscribed(Bool)
        case errorHandling(Error)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action{
        case .subscribe:
            guard !products.isEmpty else{
                return .none
            }
            return .run{send in
                let product = self.products[0]
                switch try await product.purchase(){
                case .success(let verification):
                    guard let transcation = await self.handle(result: verification) else{
                        return
                    }
                    // 구매 성공
                    await self.updateCustomerProductStatus(send: send)
                    await transcation.finish()
                default:
                   break
                }
            }
 
        case .getProducts:
            return .run{send in
                self.products = try await Product.products(for: [self.productID])
                await self.updateCustomerProductStatus(send: send)
            }catch: { error, send in
                await send(.errorHandling(error))
            }
        case .setIsSubscribed(let value):
            state.isSubscribed = value
            return .none
        case .errorHandling(let error):
            print(error.localizedDescription)
            return .none
        }
    }
    
    
    
    //MARK: - private
    private func handle(result: VerificationResult<Transaction>) async -> Transaction?{
        switch result{
        case .verified(let transaction):
            // 검증 성공
            return transaction
        default:
            return nil
        }
    }
    
    private func updateCustomerProductStatus(send: Send<Action>) async{
        for await result in Transaction.currentEntitlements{// 이미 산 것들 불러오기
            guard await self.handle(result: result) != nil else{
                return
            }
            
            guard let product = products.first, let status = try? await product.subscription?.status.first?.state else{
                return
            }
            
            await send(.setIsSubscribed(status == .subscribed))
        }
    }
    private let productID = "com.prlab.VitalWink2.subscribe2"
    private var products = [Product]()
    private var transactionListener: Task<Void, Error>?
}
