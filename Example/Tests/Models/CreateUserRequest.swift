import CodableStore

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
