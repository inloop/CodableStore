import CodableStore

struct GithubError: Decodable, CustomDateDecodable {
    let message: String
    let documentationUrl: String

    enum CodingKeys: String, CodingKey {
        case message
        case documentationUrl = "documentation_url"
    }

    public static var dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601
}
