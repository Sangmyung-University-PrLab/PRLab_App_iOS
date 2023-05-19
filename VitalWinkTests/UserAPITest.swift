//

import XCTest
import Dependencies
import Combine
import Alamofire
@testable import VitalWink

final class UserAPITest: XCTestCase {
    @Dependency(\.userAPI) var sut
    private var subscriptions = Set<AnyCancellable>()
    func test_findUser_byEmail(){
        let expectation = XCTestExpectation(description: "Performs a request")
        MockUserProtocol.responseWithUser(type: .find)
        MockUserProtocol.responseWithStatusCode(code: 200)
        sut.find(email: "test").sink(receiveCompletion: {
            switch $0{
            case .finished:
                break
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }, receiveValue: {
            XCTAssert($0 == "id")
            expectation.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 5)
    }
}
