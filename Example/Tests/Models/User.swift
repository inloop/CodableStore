import CodableStore

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
