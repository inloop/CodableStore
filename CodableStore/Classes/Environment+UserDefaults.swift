//
//  Environment+UserDefaults.swift
//  CodableStore
//
//  Created by Jakub Knejzlik on 20/03/2018.
//

import Foundation

public class CodableStoreEnvironmentUserDefaultsEndpoint<T: Decodable>: CodableStoreEnvironmentEndpoint<T> {

    func getRequest() -> UserDefaultsCodableStoreRequest {
        return UserDefaultsCodableStoreRequest(method: .get, key: self.path)
    }
}

public class CodableStoreEnvironmentUserDefaultsPayloadEndpoint<U: Encodable, T: Decodable>: CodableStoreEnvironmentUserDefaultsEndpoint<T> {
    var payload: U!

    func setPayload(_ payload: U) -> Self {
        self.payload = payload
        return self
    }

    override func getRequest() -> UserDefaultsCodableStoreRequest {
        return UserDefaultsCodableStoreRequest(method: .set(payload), key: self.path)
    }
}

public protocol CodableStoreUserDefaultsEnvironment: CodableStoreEnvironment where SourceType == String {

    typealias Endpoint = CodableStoreEnvironmentUserDefaultsEndpoint
    typealias EndpointWithPayload = CodableStoreEnvironmentUserDefaultsPayloadEndpoint
}

extension CodableStoreUserDefaultsEnvironment {
    typealias GET<T: Decodable> = CodableStoreEnvironmentUserDefaultsEndpoint<T>
    typealias SET<U: Encodable, T: Decodable> = CodableStoreEnvironmentUserDefaultsPayloadEndpoint<U,T>

    public static func request<T>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> ProviderRequestType {
        let source = sourceBase.appending(endpoint.path)

        if let endpoint = endpoint as? CodableStoreEnvironmentUserDefaultsEndpoint<T> {
            return endpoint.getRequest()
        }

        return UserDefaultsCodableStoreRequest(method: .get, key: source)
    }
}
