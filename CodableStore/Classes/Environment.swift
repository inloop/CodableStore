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
            guard let params = params else {
                return _path
            }

            var result = _path
            for (key,value) in params {
                // TODO: replace by regexp because :id could mismatch with :id_something etc.
                result = result.replacingOccurrences(of: ":\(key)", with: value)
            }

            return result
        }
        set(value) {
            _path = value
        }
    }

    public var params: [String: String]? = nil

    @discardableResult public func params(_ params: [String: String]) -> Self {
        self.params = params
        return self
    }

    @discardableResult public func setParamValue(_ value: String, forKey key: String) -> Self {
        var _params = params ?? [:]
        _params[key] = value
        self.params = _params
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

public protocol CodableStoreUserDefaultsEnvironment: CodableStoreEnvironment where SourceType == String {

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







