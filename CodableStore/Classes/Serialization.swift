//
//  Serialization.swift
//  Pods
//
//  Created by Jakub Knejzlik on 12/02/2018.
//

import Foundation

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
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(data)
    }

    public func deserialize<T>() throws -> T where T : Decodable {
        if let data = self as? T {
            return data
        } else {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: self)
        }
    }

}
