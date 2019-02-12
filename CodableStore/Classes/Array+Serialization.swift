//
//  Array+Serialization.swift
//  CodableStore
//
//  Created by Jakub Petrík on 2/1/19.
//

import Foundation

extension Array: CustomDateEncodable where Element: CustomDateEncodable {
    public static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy {
        return Element.dateEncodingStrategy
    }
}

extension Array: CustomKeyEncodable where Element: CustomKeyEncodable {
    public static var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy {
        return Element.keyEncodingStrategy
    }
}

extension Array: CustomDateDecodable where Element: CustomDateDecodable {
    public static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        return Element.dateDecodingStrategy
    }
}

extension Array: CustomKeyDecodable where Element: CustomKeyDecodable {
    public static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        return Element.keyDecodingStrategy
    }
}
