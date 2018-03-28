import Quick
import Nimble
import PromiseKit

import CodableStore

class NetworkingStatusIndicatorTests: QuickSpec {

    // Model
    struct User: Codable {
        let id: Int
        let name: String
        let username: String
    }

    // Environment
    enum TestEnvironment: CodableStoreHTTPEnvironment {

        static var sourceBase = URL(string: "http://jsonplaceholder.typicode.com")!

        static let listUsers: Endpoint<[User]> = GET("/users")
    }

    override func spec() {
        describe("logging adapter") {

            let indicator = CodableStoreNetworkActivityIndicatorAdapter<TestEnvironment>()

            let store = CodableStore(TestEnvironment.self)

            store.addAdapter(indicator)

            it("should handle indicator") {

                expect(indicator.isNetworkActivityIndicatorVisible).to(equal(false))

                store.send(TestEnvironment.listUsers).then { response in
                    return
                }

                expect(indicator.isNetworkActivityIndicatorVisible).to(equal(true))

                expect(indicator.isNetworkActivityIndicatorVisible).toEventually(equal(false))
            }
        }
    }
}

