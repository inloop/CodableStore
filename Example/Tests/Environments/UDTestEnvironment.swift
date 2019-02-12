import CodableStore

enum UDTestEnvironment: CodableStoreUserDefaultsEnvironment {
    static var sourceBase = "dummy_key"

    static let currentUser: Endpoint<User> = GET("/currentUser")
    static let setCurrentUser: EndpointWithPayload<User, User> = SET("/currentUser")
}

class UserDefaultsAdapter: CodableStoreAdapter<UDTestEnvironment> {

    var requestsHandled = 0
    var responseHandled = 0
    var errorsHandled = 0

    func resetCounters() {
        requestsHandled = 0
        responseHandled = 0
        errorsHandled = 0
    }

    override func transform(request: UserDefaultsCodableStoreRequest) -> UserDefaultsCodableStoreRequest {
        requestsHandled += 1
        return request
    }
    override func transform(response: UserDefaultsCodableStoreResult) -> UserDefaultsCodableStoreResult {
        responseHandled += 1
        return response
    }
    override func handle<T>(error: Error) throws -> T? where T: Decodable {
        errorsHandled += 1
        throw error
    }
}
