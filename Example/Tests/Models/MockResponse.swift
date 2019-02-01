import CodableStore

struct MockResponse: Decodable {
    let identifier: Int

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
    }
}
