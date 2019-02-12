//
//  Dictionary+Serialization.swift
//  CodableStore
//
//  Created by Jakub Petrík on 2/1/19.
//

import Foundation

extension Dictionary: CustomDateEncodable where Value: CustomDateEncodable, Key: Encodable {
    public static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy {
        return Value.dateEncodingStrategy
    }
}

extension Dictionary: CustomKeyEncodable where Value: CustomKeyEncodable, Key: Encodable {
    public static var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy {
        return Value.keyEncodingStrategy
    }
}

extension Dictionary: CustomDateDecodable where Value: CustomDateDecodable, Key: Decodable {
    public static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        return Value.dateDecodingStrategy
    }
}

extension Dictionary: CustomKeyDecodable where Value: CustomKeyDecodable, Key: Decodable {
    public static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        return Value.keyDecodingStrategy
    }
}
