import Quick
import Nimble
import PromiseKit

@testable import CodableStore

class EnvironmentTests: QuickSpec {

    // Model
    struct User: Codable {
        let id: Int
        let name: String
        let username: String
    }

    // Environment
    enum TestEnvironment: CodableStoreEnvironment {
        static var sourceBase: CodableStoreSource = URL(string: "http://jsonplaceholder.typicode.com")!

        static let usersList = Get<[User]>("/users")
        static let createUser = Set<User,User>("/users")
        static let userDetail = Get<User>("/users/:id")
    }

    override func spec() {
        describe("environment") {

            let store = CodableStore(TestEnvironment.self)

            it("read") {
                var ids = [Int]()

                store.get(from: TestEnvironment.usersList).then { users -> Void in
                    guard let users = users else {
                        return
                    }
                    ids.append(contentsOf:  users.map { $0.id })
                }
                expect(ids).toEventually(contain([1,2,3]), timeout: 5)
            }

            it("write") {
                var ids = [Int]()
                let user = User(id: 123, name: "John Doe", username: "john.doe")

                store.set(user, in: TestEnvironment.createUser).then { user -> Void in
                    ids.append(user!.id)
                }
                expect(ids).toEventually(contain([user.id]), timeout: 5)
            }
        }
    }
}

