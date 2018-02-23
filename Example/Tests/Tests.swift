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

            it("instance") {
                let tesla = Company(name: "Tesla")
                let teslaKey = "tesla_company"

                teslaKey.set(tesla).then { (company: Company?) -> Promise<Company?> in
                    return teslaKey.get()
                }.then { _tesla -> Void in
                    expect(tesla.name).to(equal(_tesla?.name))
                }
            }

            it("array of instances") {
                let tesla = Company(name: "Tesla")
                let spacex = Company(name: "SpaceX")

                let companiesKey = "companies"

                companiesKey.set([tesla,spacex]).then { (companies: [Company]?) -> Promise<[Company]?> in
                    return companiesKey.get()
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

            it("read") {
                let url = URL(string: "http://jsonplaceholder.typicode.com/posts")!
                var ids = [Int]()

                url.get().then { (posts: [Post]?) -> Void in
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

                url.set(post).then { (post: Post?) -> Void in
                    ids.append(post!.id)
                }
                expect(ids).toEventually(contain([post.id]), timeout: 5)
            }
        }
    }
}
