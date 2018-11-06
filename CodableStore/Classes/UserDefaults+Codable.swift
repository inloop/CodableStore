//
//  UserDefaults+Codable.swift
//  Pods
//
//  Created by Jakub Knejzlik on 12/02/2018.
//

import Foundation

public struct UserDefaultsCodableStoreRequest: CodableStoreProviderRequest {

    enum Method {
        case get
        case set(Encodable)
    }

    let method: Method
    let key: String
}

public struct UserDefaultsCodableStoreResult: CodableStoreProviderResponse {
    let data: Data?

    public func deserialize<T>() throws -> T where T : Decodable {
        guard let data = data else {
            throw CodableStoreError.emptyResponseData
        }
        return try data.deserialize()
    }
}

extension UserDefaults: CodableStoreProvider {

    public typealias RequestType = UserDefaultsCodableStoreRequest
    public typealias ResponseType = UserDefaultsCodableStoreResult

    public func send(_ request: RequestType, _ handler: @escaping ResponseHandler) {
        switch request.method {
        case .get:
            let res = UserDefaults.ResponseType(data: get(request.key))
            handler(res, nil)
        case .set(let item):
            do {
                let value = try set(item, for: request.key)
                handler(UserDefaults.ResponseType(data: value), nil)
            } catch {
                handler(nil, error)
            }
        }
    }

    private func get(_ key: String) -> Data? {
        return data(forKey: key)
    }

    private func set(_ item: Encodable, for key: String) throws -> Data? {
        let data = try item.serialize() as Data
        set(data, forKey: key)
        return get(key)
    }
}
