import CodableStore

struct CustomDateSubject: Codable, CustomDateEncodable, CustomDateDecodable, Equatable {
    let date: Date
    static var dateEncodingStrategyUsed: () -> Void = {}
    static var dateDecodingStrategyUsed: () -> Void = {}

    enum CodingKeys: String, CodingKey {
        case date
    }

    static let apiFormatter: DateFormatter = {
        let apiFormatter = DateFormatter()
        apiFormatter.calendar = Calendar(identifier: .iso8601)
        apiFormatter.locale = Locale(identifier: "en_US_POSIX")
        apiFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        apiFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return apiFormatter
    }()

    static var dateEncodingStrategy = JSONEncoder.DateEncodingStrategy.custom { (date, encoder) in
        dateEncodingStrategyUsed()
        var container = encoder.singleValueContainer()
        try container.encode(CustomDateSubject.apiFormatter.string(from: date))
    }

    static var dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.custom { (decoder) -> Date in
        dateDecodingStrategyUsed()
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        if let date =  CustomDateSubject.apiFormatter.date(from: dateString) {
            return date
        }
        fatalError("Invalid date: \(dateString)")
    }

    public static func == (lhs: CustomDateSubject, rhs: CustomDateSubject) -> Bool {
        return Calendar.current.compare(lhs.date, to: rhs.date, toGranularity: .nanosecond) == .orderedSame
    }
}
