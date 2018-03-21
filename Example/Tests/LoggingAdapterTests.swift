import Quick
import Nimble
import PromiseKit

import CodableStore

class LoggingAdapterTests: QuickSpec {

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

            var logs: [String] = []

            let logging = CodableStoreLoggingAdapter<TestEnvironment>(loggingFn: { (items: Any...) in
                logs.append((items as! [String]).joined(separator: " "))
            })

            let store = CodableStore(TestEnvironment.self)

            store.addAdapter(logging)

            it("should log") {

                store.send(TestEnvironment.listUsers).then { response in
                    return
                }

                expect(logs.count).toEventually(equal(2))
                expect(logs[0]).toEventually(equal("[CodableStore:request] curl -v -X GET 'http://jsonplaceholder.typicode.com/users'"))
                let idx = logs[1].index(logs[1].startIndex, offsetBy: 30)
                expect(logs[1][...idx]).toEventually(equal("[CodableStore:response] [\n  {\n   "[...idx]))
            }
        }
    }
}
