import CodableStore

enum GithubEnvironment: CodableStoreHTTPEnvironment {

    static var sourceBase = URL(string: "https://api.github.com")!

    static let dummy: Endpoint<User> = GET("/dummy")
    static let authorize: Endpoint<MockResponse> = GET("/")
}

class GithubAdapter: CodableStoreAdapter<GithubEnvironment> {

    var requestsHandled = 0
    var errorsHandled = 0

    func resetCounters() {
        errorsHandled = 0
        requestsHandled = 0
    }

    override func transform(request: URLRequest) -> URLRequest {
        requestsHandled += 1
        if request.url!.absoluteString == GithubEnvironment.sourceBase.absoluteString + "/" {
            var request = request
            request.setValue("Basic Zm9vOmJhcg==", forHTTPHeaderField: "Authorization")
            return request
        }
        return request
    }

    override func handle<T>(error: Error) throws -> T? where T: Decodable {
        errorsHandled += 1
        throw error
    }
}
