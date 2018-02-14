import Quick
import Nimble
import PromiseKit

@testable import CodableStore

class Tests: QuickSpec {

    struct Company: Codable {
        let name: String
    }

    override func spec() {
        describe("userdefaults store") {

            let store = CodableStore(provider: UserDefaults.standard)

            it("instance") {
                let tesla = Company(name: "Tesla")
                let teslaKey = "tesla_company"

                tesla.create(store, key: teslaKey).then { (company: Company?) -> Promise<Company?> in
                    return Company.read(store, key: teslaKey)
                }.then { _tesla -> Void in
                    expect(tesla.name).to(equal(_tesla?.name))
                }
            }

            it("array of instances") {
                let tesla = Company(name: "Tesla")
                let spacex = Company(name: "SpaceX")

                let companiesKey = "companies"

                [tesla,spacex].create(store, key: companiesKey).then { (companies: [Company]?) -> Promise<[Company]?> in
                    return [Company].read(store, key: companiesKey)
                }.then { _companies -> Void in
                    let _companyNames: [String]? = _companies?.map({ $0.name })
                    expect([tesla.name, spacex.name]).to(equal(_companyNames))
                }
            }
        }

        describe("urlSession store") {

            struct Post: Codable {
                let id: Int
                let title: String
                let body: String
            }

            let store = CodableStore(provider: URLSession.shared)

            it("read") {
                let url = URL(string: "http://jsonplaceholder.typicode.com/posts")!
                var ids = [Int]()

                [Post].read(store, key: url).then { posts -> Void in
                    guard let posts = posts else {
                        return
                    }
                    ids.append(contentsOf: posts.map { $0.id })
                }
                expect(ids).toEventually(contain([1,2,3]), timeout: 5)
            }

            it("write") {
                let url = URL(string: "http://jsonplaceholder.typicode.com/posts")!
                var ids = [Int]()
                let post = Post(id: 124, title: "title", body: "body")

                post.create(store, key: url).then { (post: Post?) -> Void in
                    ids.append(post!.id)
                }
                expect(ids).toEventually(contain([post.id]), timeout: 5)
            }
        }
    }
}
