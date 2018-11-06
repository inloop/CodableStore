import Quick
import Nimble
import PromiseKit

import CodableStore

// Model
struct LoggingUser: Codable {
    let identifier: Int
    let name: String
    let username: String

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case username
    }
}

class LoggingAdapterTests: QuickSpec {

    // Environment
    enum TestEnvironment: CodableStoreHTTPEnvironment {

        static var sourceBase = URL(string: "http://jsonplaceholder.typicode.com")!

        static let listUsers: Endpoint<[LoggingUser]> = GET("/users")
    }

    override func spec() {
        describe("logging adapter") {

            var logs: [String] = []

            let logging = CodableStoreLoggingAdapter<TestEnvironment>(loggingFn: { (items: Any...) in
                if let items = items as? [String] {
                    logs.append(items.joined(separator: " "))
                }
            })

            let store = CodableStore(TestEnvironment.self)

            store.addAdapter(logging)

            it("should log") {

                store.send(TestEnvironment.listUsers)

                expect(logs.count).toEventually(equal(2))
                expect(logs.first).toEventually(equal("[CodableStore:request] curl -v -X GET 'http://jsonplaceholder.typicode.com/users'"))
                let idx = logs[1].index(logs[1].startIndex, offsetBy: 30)
                expect(logs[1][...idx]).toEventually(equal("[CodableStore:response] [\n  {\n   "[...idx]))
            }
        }
    }
}
