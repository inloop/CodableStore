import CodableStore

struct GithubErrorSnakeCase: Decodable, CustomDateDecodable, CustomKeyDecodable {
    let message: String
    let documentationUrl: String

    public static var dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601
    public static var keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
}
