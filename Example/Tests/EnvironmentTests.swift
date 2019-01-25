import Quick
import Nimble
import PromiseKit

import CodableStore

// Model
struct User: Codable, CustomDateDecodable, CustomDateEncodable {
    let identifier: Int
    let name: String
    let username: String
    let birthdate: Date?

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case username
        case birthdate
    }

    static let apiFormatter: DateFormatter = {
        let apiFormatter = DateFormatter()
        apiFormatter.calendar = Calendar(identifier: .iso8601)
        apiFormatter.locale = Locale(identifier: "en_US_POSIX")
        apiFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        apiFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return apiFormatter
    }()

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
    let identifier: Int
    let name: String
    let username: String

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case username
    }

    static var dateEncodingStrategy = JSONEncoder.DateEncodingStrategy.iso8601
}

struct GithubError: Decodable, CustomDateDecodable {
    let message: String
    let documentationUrl: String

    enum CodingKeys: String, CodingKey {
        case message
        case documentationUrl = "documentation_url"
    }

    public static var dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601
}

struct GithubErrorSnakeCase: Decodable, CustomDateDecodable, CustomKeyDecodable {
    let message: String
    let documentationUrl: String

    public static var dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601
    public static var keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
}

struct MockResponse: Decodable {
    let identifier: Int

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
    }
}

struct CustomDateSubject: Codable, CustomDateEncodable, CustomDateDecodable, Equatable {
    let date: Date
    static var dateEncodingStrategyUsed: () -> Void = {}
    static var dateDecodingStrategyUsed: () -> Void = {}

    enum CodingKeys: String, CodingKey {
        case date
    }

    static var dateEncodingStrategy = JSONEncoder.DateEncodingStrategy.custom { (date, encoder) in
        dateEncodingStrategyUsed()
        var container = encoder.singleValueContainer()
        try container.encode(User.apiFormatter.string(from: date))
    }

    static var dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.custom { (decoder) -> Date in
        dateDecodingStrategyUsed()
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        if let date =  User.apiFormatter.date(from: dateString) {
            return date
        }
        fatalError("Invalid date: \(dateString)")
    }

    public static func == (lhs: CustomDateSubject, rhs: CustomDateSubject) -> Bool {
        return Calendar.current.compare(lhs.date, to: rhs.date, toGranularity: .nanosecond) == .orderedSame
    }
}

class EnvironmentTests: QuickSpec {

    // Environment
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
            errorsHandled += 1
            throw error
        }
    }

    // Github Environment
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

    // UserDefaults Environment
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

    // swiftlint:disable:next function_body_length
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

                store.send(TestEnvironment.listUsers).done { (users: [User]) -> Void in
                    ids.append(contentsOf: users.map { $0.identifier })
                }.cauterize()
                expect(ids).toEventually(contain([1, 2, 3]), timeout: 5)
                expect(adapter.requestsHandled).to(equal(1))
                expect(adapter.responseHandled).to(equal(1))
                expect(adapter.errorsHandled).to(equal(0))
            }

            it("write") {
                var ids = [Int]()
                let user = CreateUserRequest(identifier: 11, name: "John Doe", username: "john.doe")

                adapter.resetCounters()

                let endpoint = TestEnvironment.createUser.body(body: user)

                store.send(endpoint).done { (user: User) -> Void in
                    ids.append(user.identifier)
                }.cauterize()
                expect(ids).toEventually(contain([user.identifier]), timeout: 5)
                expect(adapter.requestsHandled).to(equal(1))
                expect(adapter.responseHandled).to(equal(1))
                expect(adapter.errorsHandled).to(equal(0))
            }

            it("write userdefaults") {
                var ids = [Int]()
                let user = User(identifier: 123, name: "John Doe", username: "john.doe", birthdate: Date(timeIntervalSince1970: 3600*24*30*12*35))

                userDefaultsAdapter.resetCounters()

                let endpoint = UDTestEnvironment.setCurrentUser.setPayload(user)
                userDefaultsStore.send(endpoint).done { (user: User?) in
                    guard let user = user else {
                        return
                    }
                    ids.append(user.identifier)
                }.cauterize()

                expect(ids).toEventually(contain([user.identifier]), timeout: 5)
                expect(userDefaultsAdapter.requestsHandled).to(equal(1))
                expect(userDefaultsAdapter.responseHandled).to(equal(1))
                expect(userDefaultsAdapter.errorsHandled).to(equal(0))
            }

            it("request params") {
                let endpoint = TestEnvironment.userDetail.with(value: "123", forParameter: "id")

                let path = endpoint.path
                let request = endpoint.getRequest(url: URL(string: "http://example.com")!)

                expect(path).to(equal("/users/123"))
                expect(request.url?.absoluteString).to(equal("http://example.com/users/123"))
            }

            it("request query") {
                let endpoint = TestEnvironment.listUsers.query(["foo": "dummy"])
                endpoint.setQueryValue("bb", forKey: "aa")

                let request = endpoint.getRequest(url: URL(string: "http://example.com")!)

                expect(request.url?.absoluteString).to(contain("http://example.com/users"))
                expect(request.url?.absoluteString).to(contain("aa=bb"))
                expect(request.url?.absoluteString).to(contain("foo=dummy"))
            }

            it("error parsing") {
                var errorMessage: String? = nil
                let endpoint = GithubEnvironment.dummy

                githubAdapter.resetCounters()

                githubStore.send(endpoint).catch { error in
                    guard let error = error as? URLSessionCodableError else {
                        return
                    }
                    switch error {
                    case .unexpectedStatusCode(let response):
                        let errorData: GithubError? = try? response.decodeData()
                        errorMessage = errorData?.message
                    case .unexpectedError:
                        break
                    }
                }
                expect(errorMessage).toEventually(equal("Not Found"), timeout: 5)
                expect(githubAdapter.requestsHandled).to(equal(1))
                expect(githubAdapter.errorsHandled).to(equal(1))
            }

            it("error parsing (SnakeCase decoding)") {
                var errorMessage: String? = nil
                let endpoint = GithubEnvironment.dummy

                githubAdapter.resetCounters()

                githubStore.send(endpoint).catch { error in
                    guard let error = error as? URLSessionCodableError else {
                        return
                    }
                    switch error {
                    case .unexpectedStatusCode(let response):
                        let errorData: GithubErrorSnakeCase? = try? response.decodeData()
                        errorMessage = errorData?.message
                    case .unexpectedError:
                        break
                    }
                }
                expect(errorMessage).toEventually(equal("Not Found"), timeout: 5)
                expect(githubAdapter.requestsHandled).to(equal(1))
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

            it("correctly substitutes parameters") {
                let (value1, value2) = ("foo", "bar")
                let expectedPath = TestEnvironment.sourceBase
                    .appendingPathComponent("users")
                    .appendingPathComponent(value1)
                    .appendingPathComponent(value2)
                    .path
                let actualPath = TestEnvironment.twoParams
                    .with(value: value1, forParameter: "id")
                    .with(value: value2, forParameter: "id_something")
                    .path

                expect(actualPath).to(equal(expectedPath))
            }

            it("encodes and decodes using custom strategy") {
                var encoded = false
                var decoded = false

                CustomDateSubject.dateEncodingStrategyUsed = {
                    encoded = true
                }
                CustomDateSubject.dateDecodingStrategyUsed = {
                    decoded = true
                }

                do {
                    let expected = CustomDateSubject(date: Date())
                    let data: Data = try expected.serialize()
                    let actual: CustomDateSubject = try data.deserialize()
                    expect(actual).to(equal(expected))
                } catch {
                    fail(error.localizedDescription)
                }

                expect([encoded, decoded]).toEventually(equal([true, true]))
            }
        }
    }
}
