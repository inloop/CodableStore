//
//  Environment+KeyedStoreProvider.swift
//  CodableStore
//
//  Created by Jakub Knejzlik on 20/03/2018.
//

import Foundation

public class CodableStoreEnvironmentKeyedStoreProviderEndpoint<T: Decodable>: CodableStoreEnvironmentEndpoint<T> {

    public override init(_ path: String) {
        super.init(path)
    }

    public func getRequest() -> KeyedStoreRequest {
        return .get(key: path)
    }
}

public class CodableStoreEnvironmentKeyedStoreProviderPayloadEndpoint<U: Encodable, T: Decodable>: CodableStoreEnvironmentKeyedStoreProviderEndpoint<T> {
    var payload: U!

    public func setPayload(_ payload: U) -> Self {
        self.payload = payload
        return self
    }

    override public func getRequest() -> KeyedStoreRequest {
        return .set(key: path, value: payload)
    }
}

public protocol CodableStoreKeyedStoreProviderEnvironment: CodableStoreEnvironment where SourceType == String {
    typealias Endpoint = CodableStoreEnvironmentKeyedStoreProviderEndpoint
    typealias EndpointWithPayload = CodableStoreEnvironmentKeyedStoreProviderPayloadEndpoint
}

extension CodableStoreKeyedStoreProviderEnvironment {
    public typealias GET<T: Decodable> = CodableStoreEnvironmentKeyedStoreProviderEndpoint<T>
    public typealias SET<U: Encodable, T: Decodable> = CodableStoreEnvironmentKeyedStoreProviderPayloadEndpoint<U,T>

    public static func request<T>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> ProviderRequestType {
        let source = sourceBase.appending(endpoint.path)

        if let endpoint = endpoint as? CodableStoreEnvironmentKeyedStoreProviderEndpoint<T> {
            return endpoint.getRequest()
        }

        return .get(key: source)
    }
}
