import Quick
import Nimble
import PromiseKit

import CodableStore

class Tests: QuickSpec {

    struct Company: Codable {
        let name: String
    }

    override func spec() {
        describe("userdefaults store") {

            it("instance") {
                let tesla = Company(name: "Tesla")
                let teslaKey = "tesla_company"

                teslaKey.set(tesla).then { (_: Company?) -> Promise<Company?> in
                    return teslaKey.get()
                }.done { result in
                    expect(tesla.name).to(equal(result!.name))
                }.cauterize()
            }

            it("array of instances") {
                let tesla = Company(name: "Tesla")
                let spacex = Company(name: "SpaceX")

                let companiesKey = "companies"

                companiesKey.set([tesla, spacex]).then { (_: Company?) -> Promise<[Company]?> in
                    return companiesKey.get()
                }.done { (companies: [Company]?) in
                    let companyNames: [String]? = companies?.map({ $0.name })
                    expect([tesla.name, spacex.name]).to(equal(companyNames))
                }.cauterize()
            }
        }

        describe("urlSession store") {

            struct Post: Codable {
                let identifier: Int
                let title: String
                let body: String

                enum CodingKeys: String, CodingKey {
                    case identifier = "id"
                    case title
                    case body
                }
            }

            it("read") {
                let url = URL(string: "http://jsonplaceholder.typicode.com/posts")!
                var ids = [Int]()

                url.get().done { (posts: [Post]?) -> Void in
                    guard let posts = posts else {
                        return
                    }
                    ids.append(contentsOf: posts.map { $0.identifier })
                }.cauterize()

                expect(ids).toEventually(contain([1, 2, 3]), timeout: 5)
            }

            it("write") {
                let url = URL(string: "http://jsonplaceholder.typicode.com/posts")!
                var ids = [Int]()
                let post = Post(identifier: 124, title: "title", body: "body")

                url.set(post).done { (post: Post?) -> Void in
                    ids.append(post!.identifier)
                }.cauterize()
                expect(ids).toEventually(contain([post.identifier]), timeout: 5)
            }
        }
    }
}
