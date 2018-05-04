//  Copyright © 2018 INLOOPX. All rights reserved.

import PromiseKit

public enum KeyedStoreRequest: CodableStoreProviderRequest {
    case get(key: String)
    case set(key: String, value: Encodable)
}

public struct KeyedStoreResponse: CodableStoreProviderResponse {
    let data: Data?

    public func deserialize<T>() throws -> T where T : Decodable {
        guard let data = data else {
            throw CodableStoreError.emptyResponseData
        }
        return try data.deserialize()
    }
}

public protocol KeyedStoreProvider: CodableStoreProvider {
    func data(forKey: String) -> Data?
    func set(data: Data, forKey key: String)
}

extension KeyedStoreProvider where RequestType == KeyedStoreRequest, ResponseType == KeyedStoreResponse {

    public func send(_ request: KeyedStoreRequest) -> Promise<KeyedStoreResponse> {
        switch request {
        case .get(let key):
            return Promise(value: KeyedStoreResponse(data: data(forKey: key)))
        case .set(let key, let value):
            do {
                let encoded = try set(value, forKey: key)
                return Promise(value: KeyedStoreResponse(data: encoded))
            } catch {
                return Promise(error: error)
            }
        }
    }

    private func set(_ value: Encodable, forKey key: String) throws -> Data? {
        let encoded = try value.serialize() as Data
        set(data: encoded, forKey: key)
        return data(forKey: key)
    }
}

