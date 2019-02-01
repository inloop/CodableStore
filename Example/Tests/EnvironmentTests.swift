import Quick
import Nimble
import PromiseKit
@testable import CodableStore

class EnvironmentTests: QuickSpec {

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
                var errorMessage: String?
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
                var errorMessage: String?
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
                var authError: Error?
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

            it("encodes using custom date strategy") {
                var encoded = false

                CustomDateSubject.dateEncodingStrategyUsed = {
                    encoded = true
                }

                let expected = CustomDateSubject(date: Date())
                store
                    .send(FakeAPIEnvironment.createDate.body(body: expected))
                    .done { actual in
                        expect(actual).to(equal(expected))
                    }
                    .catch { error in
                        fail(error.localizedDescription)
                    }

                expect(encoded).toEventually(equal(true))
            }

            it("decodes using custom date strategy") {
                var decoded = false

                CustomDateSubject.dateDecodingStrategyUsed = {
                    decoded = true
                }

                let store = CodableStore(FakeAPIEnvironment.self)
                store
                    .send(FakeAPIEnvironment.date)
                    .done { actual in
                        let expected = CustomDateSubject(
                            date: CustomDateSubject.apiFormatter.date(from: "2018-01-15T00:00:00")!
                        ) // https://github.com/jakubpetrik/fake-api/blob/master/db.json
                        expect(actual).to(equal(expected))
                    }
                    .catch { error in
                        fail(error.localizedDescription)
                    }

                expect(decoded).toEventually(equal(true))
            }
        }

        it("decodes array using custom date strategy") {
            var decoded = false

            CustomDateSubject.dateDecodingStrategyUsed = {
                decoded = true
            }

            let store = CodableStore(FakeAPIEnvironment.self)
            store
                .send(FakeAPIEnvironment.dates)
                .done { actual in
                    let expectedItem = CustomDateSubject(
                        date: CustomDateSubject.apiFormatter.date(from: "2018-01-15T00:00:00")!
                    ) // https://github.com/jakubpetrik/fake-api/blob/master/db.json
                    let expectedItems = Array(repeating: expectedItem, count: 3)
                    expect(actual).to(equal(expectedItems))
                }
                .catch { error in
                    fail(error.localizedDescription)
                }

            expect(decoded).toEventually(equal(true))
        }
    }
}
