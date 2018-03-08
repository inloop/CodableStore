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
    struct CreateUserRequest: Codable {
        let id: Int
        let name: String
        let username: String
    }

    // Environment
    enum TestEnvironment: CodableStoreHTTPEnvironment {
        
        static var sourceBase = URL(string: "http://jsonplaceholder.typicode.com")!

        static let listUsers: Endpoint<[User]> = GET("/users")
        static let createUser: EndpointWithPayload<CreateUserRequest,User> = POST("/users")
        static let userDetail: EndpointWithPayload<CreateUserRequest,User> = POST("/users/:id")
    }

    override func spec() {
        describe("environment") {

            let store = CodableStore(TestEnvironment.self)

            it("read") {
                var ids = [Int]()

                store.send(TestEnvironment.listUsers).then { users -> Void in
                    guard let users = users else {
                        return
                    }
                    ids.append(contentsOf:  users.map { $0.id })
                }
                expect(ids).toEventually(contain([1,2,3]), timeout: 5)
            }

            it("write") {
                var ids = [Int]()
                let user = CreateUserRequest(id:123, name: "John Doe", username: "john.doe")

                let endpoint = TestEnvironment.createUser.body(body: user)

                store.send(endpoint).then { user -> Void in
                    ids.append(user!.id)
                }
                expect(ids).toEventually(contain([user.id]), timeout: 5)
            }

            it("request params") {
                let endpoint = TestEnvironment.userDetail.setParamValue("123", forKey: "id")

                let path = endpoint.path
                let request = endpoint.getRequest(url: URL(string: "http://example.com")!)

                expect(path).to(equal("/users/123"))
                expect(request.url?.absoluteString).to(equal("http://example.com/users/123"))
            }

            it("request query") {
                let endpoint = TestEnvironment.listUsers.query(["foo":"blah"])
                endpoint.setQueryValue("bb", forKey: "aa")

                let request = endpoint.getRequest(url: URL(string: "http://example.com")!)

                expect(request.url?.absoluteString).to(equal("http://example.com/users?aa=bb&foo=blah"))
            }
        }
    }
}

