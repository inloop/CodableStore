//
//  Serialization.swift
//  Pods
//
//  Created by Jakub Knejzlik on 12/02/2018.
//

import Foundation

public protocol CustomDateEncodable: Encodable {
    static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get }
}

public protocol CustomKeyEncodable: Encodable {
    static var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy { get }
}

public protocol CustomDateDecodable: Decodable {
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
}

public protocol CustomKeyDecodable: Decodable {
    static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
}

public extension Encodable {
    public func serialize<T: CodableStoreSerializer>() throws -> T {
        return try T.serialize(data: self)
    }
}

public extension Decodable {
    public static func deserialize<T: CodableStoreDeserializer>(input: T) throws -> Self {
        return try input.deserialize()
    }
}

public protocol CodableStoreSerializer {
    static func serialize<T: Encodable>(data: T) throws -> Self
}

public protocol CodableStoreDeserializer {
    func deserialize<T: Decodable>() throws -> T
}

extension Data: CodableStoreSerializer, CodableStoreDeserializer {
    public static func serialize<T: Encodable>(data: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = (T.self as? CustomDateEncodable.Type)?.dateEncodingStrategy ?? .iso8601
        encoder.keyEncodingStrategy = (T.self as? CustomKeyEncodable.Type)?.keyEncodingStrategy ?? .useDefaultKeys
        return try encoder.encode(data)
    }

    public func deserialize<T: Decodable>() throws -> T {
        if let data = self as? T {
            return data
        } else {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = (T.self as? CustomDateDecodable.Type)?.dateDecodingStrategy ?? .iso8601
            decoder.keyDecodingStrategy = (T.self as? CustomKeyDecodable.Type)?.keyDecodingStrategy ?? .useDefaultKeys
            return try decoder.decode(T.self, from: self)
        }
    }


}
