import Quick
import Nimble
import PromiseKit

import CodableStore

class EnvironmentTests: QuickSpec {

    static let apiFormatter: DateFormatter = {
        let apiFormatter = DateFormatter()
        apiFormatter.calendar = Calendar(identifier: .iso8601)
        apiFormatter.locale = Locale(identifier: "en_US_POSIX")
        apiFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        apiFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return apiFormatter
    }()

    // Model
    struct User: Codable, CustomDateDecodable, CustomDateEncodable {
        let id: Int
        let name: String
        let username: String
        let birthdate: Date?

        static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .formatted(apiFormatter)

        public static var dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.custom { (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            let formatter = apiFormatter
            if let date = formatter.date(from: dateStr) {
                return date
            }
            fatalError("Invalid date: \(dateStr)")
        }
    }

    struct CreateUserRequest: Codable, CustomDateEncodable {
        let id: Int
        let name: String
        let username: String

        static var dateEncodingStrategy = JSONEncoder.DateEncodingStrategy.iso8601
    }

    struct MockResponse: Decodable {
        let id: Int
    }

    // Environment
    enum TestEnvironment: CodableStoreHTTPEnvironment {

        static var sourceBase = URL(string: "http://jsonplaceholder.typicode.com")!

        static let listUsers: Endpoint<[User]> = GET("/users")
        static let createUser: EndpointWithPayload<CreateUserRequest,User> = POST("/users")
        static let userDetail: EndpointWithPayload<CreateUserRequest,User> = POST("/users/:id")
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
        override func handle<T>(error: Error) throws -> T? where T : Decodable {
            errorsHandled += 1
            throw error
        }
    }

    // Github Environment

    struct GithubError: Decodable, CustomDateDecodable {
        let message: String
        let documentation_url: String

        public static var dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601
    }

    enum GithubEnvironment: CodableStoreHTTPEnvironment {

        static var sourceBase = URL(string: "https://api.github.com")!

        static let blah: Endpoint<User> = GET("/blah")
        static let authorize: Endpoint<MockResponse> = GET("/")
    }

    class GithubAdapter: CodableStoreAdapter<GithubEnvironment> {

        var errorsHandled = 0

        func resetCounters() {
            errorsHandled = 0
        }

        override func transform(request: URLRequest) -> URLRequest {
            if request.url!.absoluteString == GithubEnvironment.sourceBase.absoluteString + "/" {
                var request = request
                request.setValue("Basic Zm9vOmJhcg==", forHTTPHeaderField: "Authorization")
                return request
            }
            return request
        }

        override func handle<T>(error: Error) throws -> T? where T : Decodable {
            errorsHandled += 1
            throw error
        }
    }

    // UserDefaults Environment
    enum UDTestEnvironment: CodableStoreUserDefaultsEnvironment {
        static var sourceBase = "blah_key"

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
        override func handle<T>(error: Error) throws -> T? where T : Decodable {
            errorsHandled += 1
            throw error
        }
    }

    override func spec() {
        describe("environment") {

            let adapter = TestAdapter()
            let githubAdapter = GithubAdapter()
            let userDefaultsAdapter = UserDefaultsAdapter()
            let store = CodableStore(TestEnvironment.self)
            let githubStore = CodableStore(GithubEnvironment.self)
            let userDefaultsStore = CodableStore(UDTestEnvironment.self)

            store.addAdapter(adapter)
            githubStore.addAdapter(githubAdapter)
            userDefaultsStore.addAdapter(userDefaultsAdapter)

            it("read") {
                var ids = [Int]()

                adapter.resetCounters()

                store.send(TestEnvironment.listUsers).then { users -> Void in
                    ids.append(contentsOf:  users.map { $0.id })
                }
                expect(ids).toEventually(contain([1,2,3]), timeout: 5)
                expect(adapter.requestsHandled).to(equal(1))
                expect(adapter.responseHandled).to(equal(1))
                expect(adapter.errorsHandled).to(equal(0))
            }

            it("write") {
                var ids = [Int]()
                let user = CreateUserRequest(id:123, name: "John Doe", username: "john.doe")

                adapter.resetCounters()

                let endpoint = TestEnvironment.createUser.body(body: user)

                store.send(endpoint).then { user -> Void in
                    ids.append(user.id)
                }
                expect(ids).toEventually(contain([user.id]), timeout: 5)
                expect(adapter.requestsHandled).to(equal(1))
                expect(adapter.responseHandled).to(equal(1))
                expect(adapter.errorsHandled).to(equal(0))
            }

            it("write userdefaults") {
                var ids = [Int]()
                let user = User(id: 123, name: "John Doe", username: "john.doe", birthdate: Date(timeIntervalSince1970: 3600*24*30*12*35))

                userDefaultsAdapter.resetCounters()

                let endpoint = UDTestEnvironment.setCurrentUser.setPayload(user)

                userDefaultsStore.send(endpoint).then { user -> Void in
                    ids.append(user.id)
                }
                expect(ids).toEventually(contain([user.id]), timeout: 5)
                expect(userDefaultsAdapter.requestsHandled).to(equal(1))
                expect(userDefaultsAdapter.responseHandled).to(equal(1))
                expect(userDefaultsAdapter.errorsHandled).to(equal(0))
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

            it("error parsing") {
                var errorMessage: String? = nil
                let endpoint = GithubEnvironment.blah

                githubAdapter.resetCounters()

                githubStore.send(endpoint).catch { error in
                    guard let error = error as? URLSessionCodableError else {
                        return
                    }
                    switch error {
                    case .unexpectedStatusCode(let response):
                        let errorData: GithubError? = try? response.decodeData()
                        errorMessage = errorData?.message
                        break;
                    case .unexpectedError(_):
                        break;
                    }
                }
                expect(errorMessage).toEventually(equal("Not Found"), timeout: 5)
                expect(githubAdapter.errorsHandled).to(equal(1))
            }

            it("catches 401") {
                var authError: Error? = nil
                githubAdapter.resetCounters()
                githubStore
                    .send(GithubEnvironment.authorize)
                    .catch { error in
                        authError = error
                    }
                expect(authError).toEventuallyNot(beNil(), timeout: 5)
            }
        }
    }
}

