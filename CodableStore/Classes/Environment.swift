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
            return parameters.reduce(_path) { path, pair in
                path.replacingOccurrences(
                    of: ":\(pair.key)\\b",
                    with: pair.value,
                    options: .regularExpression
                )
            }
        }
        set {
            _path = newValue
        }
    }

    public private(set) var parameters: [String: String] = [:]

    @discardableResult public func with(parameters: [String: String]) -> Self {
        self.parameters = parameters
        return self
    }

    @discardableResult public func with(value: String, forParameter key: String) -> Self {
        parameters[key] = value
        return self
    }

    init(_ path: String) {
        _path = path
    }
}

public protocol CodableStoreEnvironment {
    associatedtype SourceType: CodableStoreSource
    typealias ProviderRequestType = SourceType.Provider.RequestType
    typealias ProviderResponseType = SourceType.Provider.ResponseType
    static var sourceBase: SourceType { get }

    static func request<T>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> CodableStoreRequest<T, Self>
    static func providerRequest<T: Decodable>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> ProviderRequestType 
}




