import CodableStore

enum TestEnvironment: CodableStoreHTTPEnvironment {

    static var sourceBase = URL(string: "http://jsonplaceholder.typicode.com")!

    static let listUsers: Endpoint<[User]> = GET("/users")
    static let createUser: EndpointWithPayload<CreateUserRequest, User> = POST("/users")
    static let userDetail: EndpointWithPayload<CreateUserRequest, User> = POST("/users/:id")
    static let twoParams: Endpoint<User> = GET("/users/:id/:id_something")
}

class TestAdapter: CodableStoreAdapter<TestEnvironment> {

    var requestsHandled = 0
    var responseHandled = 0
    var errorsHandled = 0

    func resetCounters() {
        requestsHandled = 0
        responseHandled = 0
        errorsHandled = 0
    }

    override func transform(request: URLRequest) -> URLRequest {
        requestsHandled += 1
        return request
    }
    override func transform(response: URLSessionCodableResponse) -> URLSessionCodableResponse {
        responseHandled += 1
        return response
    }
    override func handle<T>(error: Error) throws -> T? where T: Decodable {
        print("<<<<< TestAdapter.handle(error:) \(error.localizedDescription)")
        errorsHandled += 1
        throw error
    }
}
