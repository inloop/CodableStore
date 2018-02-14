//
//  UserDefaults+Codable.swift
//  Pods
//
//  Created by Jakub Knejzlik on 12/02/2018.
//

import Foundation
import PromiseKit

extension UserDefaults: CodableStoreProvider {

    public typealias KeyType = String

    public func read<T>(key: String) -> Promise<T?> where T : Decodable {
        guard let data = data(forKey: key) else {
            return Promise(value: nil)
        }
        do {
            return Promise(value: try data.deserialize())
        } catch {
            return Promise(error: error)
        }
    }

    public func create<T, U>(_ item: T, for key: String) -> Promise<U?> where T : Encodable, U : Decodable {
        do {
            let data = try item.serialize() as Data
            set(data, forKey: key)
        } catch {
            return Promise(error: error)
        }
        return read(key: key)
    }
}
