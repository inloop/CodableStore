//
//  Environment.swift
//  CodableStore
//
//  Created by Jakub Knejzlik on 24/02/2018.
//

import Foundation
import PromiseKit

public class CodableStoreEnvironmentEndpoint<T: Decodable> {

    public typealias ResultType = T
    public let path: String

    init(_ path: String) {
        self.path = path
    }
}

public protocol CodableStoreEnvironmentable {
    func requestForEndpoint()
}

public protocol CodableStoreEnvironment {
    associatedtype SourceType: CodableStoreSource
    typealias ProviderRequestType = SourceType.Provider.RequestType
    static var sourceBase: SourceType { get }

    static func request<T>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> ProviderRequestType
}

public protocol CodableStoreUserDefaultsEnvironment: CodableStoreEnvironment {
    typealias SourceType = String

//    typealias Get<T> = CodableStoreEnvironmentEndpoint<T>
//    typealias Set<IN: Encodable, OUT> = CodableStoreEnvironmentEndpoint<IN, OUT>
}

extension CodableStoreUserDefaultsEnvironment {
    static func request<T>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> ProviderRequestType {
        let source = sourceBase.appending(endpoint.path)
        return UserDefaultsCodableStoreRequest(method: .get, key: source)
    }
}

extension CodableStore {
    public func send<T>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> Promise<T?> {
        let request = environment.request(endpoint)
        return send(request)
    }
}







