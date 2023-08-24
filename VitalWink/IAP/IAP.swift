//
//  IAP.swift
//  VitalWink
//
//  Created by 유호준 on 2023/08/17.
//

import ComposableArchitecture
import StoreKit
struct IAP:ReducerProtocol{
    init(){
        self.transactionListener =  Task.detached{
            for await result in Transaction.updates{
                switch result{
                case .verified(let transaction):
                    // 검증 성공
                    await transaction.finish()
                default:
                    break
                }
            }
        }
    }

    struct State: Equatable{
        fileprivate(set) var isSubscribed = false
        fileprivate(set) var products = [Product]()
    }
    enum Action{
        case subscribe
        case getProducts
        case setProducts([Product])
        case setIsSubscribed(Bool)
        case errorHandling(Error)
        case onDisappear
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action{
        case .onDisappear:
            return .none
        case .setProducts(let products):
            state.products = products
            return .none
        case .subscribe:
            guard !state.products.isEmpty else{
                print("?")
                return .none
            }
            return .run{[product = state.products[0]]send in
                switch try await product.purchase(){
                case .success(let verification):
                    guard let transcation = await self.handle(result: verification) else{
                        return
                    }
                    // 구매 성공
                    await self.updateCustomerProductStatus(send: send, product: product)
                    await transcation.finish()
                default:
                   break
                }
            }
 
        case .getProducts:
            return .run{send in
                let products = try await Product.products(for: [self.productID])
                
                guard !products.isEmpty else{
                    return
                }
                
                await send(.setProducts(products))
                await self.updateCustomerProductStatus(send: send, product: products[0])
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
    
    private func updateCustomerProductStatus(send: Send<Action>, product: Product) async{
        for await result in Transaction.currentEntitlements{// 이미 산 것들 불러오기
            guard await self.handle(result: result) != nil else{
                return
            }
            
            guard let status = try? await product.subscription?.status.first?.state else{
                return
            }
            
            await send(.setIsSubscribed(status == .subscribed))
        }
    }
    private let productID = "com.prlab.VitalWink2.subscribe2"
    
    private var transactionListener: Task<Void, Error>?
}
