//
//  UserDefaults+Codable.swift
//  Pods
//
//  Created by Jakub Knejzlik on 12/02/2018.
//

import Foundation
import PromiseKit

public struct UserDefaultsCodableStoreRequest: CodableStoreProviderRequest {

    enum Method {
        case get
        case set(Encodable)
    }

    let method: Method
    let key: String
}

extension UserDefaults: CodableStoreProvider {

    public typealias RequestType = UserDefaultsCodableStoreRequest

    public func send<T>(_ request: UserDefaults.RequestType) -> Promise<T?> where T : Decodable {
        switch request.method {
        case .get:
            return get(request.key)
        case .set(let item):
            return set(item, for: request.key)
        }
    }

    private func get<T: Decodable>(_ key: String) -> Promise<T?> {
        guard let data = data(forKey: key) else {
            return Promise(value: nil)
        }
        do {
            return Promise(value: try data.deserialize())
        } catch {
            return Promise(error: error)
        }
    }

    private func set<T: Decodable>(_ item: Encodable, for key: String) -> Promise<T?> {
        do {
            let data = try item.serialize() as Data
            set(data, forKey: key)
        } catch {
            return Promise(error: error)
        }
        return get(key)
    }
}
