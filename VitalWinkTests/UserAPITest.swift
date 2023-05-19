//

import XCTest
import Dependencies
import Combine
import Alamofire
@testable import VitalWink

final class UserAPITest: XCTestCase {
    @Dependency(\.userAPI) var sut
    private var subscriptions = Set<AnyCancellable>()
    private let expectation = XCTestExpectation(description: "Performs a request")
    
    func test_findId_byEmail(){        MockUserProtocol.responseWithData(type: .find)
        MockUserProtocol.responseWithStatusCode(code: 200)
        
        sut.find(email: "test").sink(receiveCompletion: {
            switch $0{
            case .finished:
                break
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }, receiveValue: {
            guard let id = $0 else{
                XCTFail("id == nil")
                return
            }
            XCTAssert(id == "id")
            self.expectation.fulfill()
        }).store(in: &subscriptions)
        wait(for: [expectation], timeout: 5)
    }
    
    func test_findId_byEmail_whenNotFound(){
        MockUserProtocol.responseWithStatusCode(code: 404)
        sut.find(email: "test").sink(receiveCompletion: {
            switch $0{
            case .finished:
                break
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }, receiveValue: {
            XCTAssertNil($0)
            self.expectation.fulfill()
        }).store(in: &subscriptions)
        wait(for: [expectation], timeout: 5)
    }
    
    func test_isIdNotExist(){
        MockUserProtocol.responseWithStatusCode(code: 204)
        sut.isIdNotExist("test").sink(receiveCompletion: {
            switch $0{
            case .finished:
                break
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }, receiveValue: {
            XCTAssertFalse($0)
            self.expectation.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_isIdNotExist_whenIdExist(){
        MockUserProtocol.responseWithStatusCode(code: 404)
        sut.isIdNotExist("test").sink(receiveCompletion: {
            switch $0{
            case .finished:
                break
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }, receiveValue: {
            XCTAssertTrue($0)
            self.expectation.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_regist(){
        MockUserProtocol.responseWithStatusCode(code: 204)
        sut.regist(User(id: "id", password: "111", email: "test@test.com", gender: .man, birthday: Date()))
            .sink(receiveCompletion: {
                switch $0{
                case .finished:
                    break
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }, receiveValue: {_ in
                
            }).store(in: &subscriptions)
    }
}
