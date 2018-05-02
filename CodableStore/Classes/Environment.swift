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
    private var _path: String
    public var path: String {
        get {
            return params.reduce(_path) { path, pair in
                path.replacingOccurrences(
                    of: ":\(pair.key)\\b",
                    with: pair.value,
                    options: .regularExpression
                )
            }
        }
        set(value) {
            _path = value
        }
    }

    public var params: [String: String] = [:]

    @discardableResult public func setParams(_ params: [String: String]) -> Self {
        self.params = params
        return self
    }

    @discardableResult public func setParamValue(_ value: String, forKey key: String) -> Self {
        params[key] = value
        return self
    }

    init(_ path: String) {
        _path = path
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

extension CodableStore {
    public func send<T>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> Promise<T> {
        let request = environment.request(endpoint)
        return send(request)
    }
}




