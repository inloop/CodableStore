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

public class CodableStoreEnvironmentHTTPEndpoint<T: Decodable>: CodableStoreEnvironmentEndpoint<T> {

//    public var query: U? = nil
//    func query(query: U) -> Self {
//        self.query = query
//        return self
//    }

    func getRequest(url: URL) -> URLRequest {
        return URLRequest(url: url)
    }
}

public class CodableStoreEnvironmentHTTPBodyEndpoint<T: Decodable>: CodableStoreEnvironmentHTTPEndpoint<T> {
//    public var body: U? = nil
//    func body(body: U) -> Self {
//        self.body = body
//        return self
//    }
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
//    typealias EndpointType = CodableStoreEnvironmentHTTPEndpoint
//    typealias Get<IN, OUT: Decodable> = CodableStoreEnvironmentEndpoint<IN, OUT>
//    typealias Set<IN: Encodable, OUT> = CodableStoreEnvironmentEndpoint<IN, OUT>
}

extension CodableStoreUserDefaultsEnvironment {
    static func request<T>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> ProviderRequestType {
        let source = sourceBase.appending(endpoint.path)
        return UserDefaultsCodableStoreRequest(method: .get, key: source)
    }
}

public protocol CodableStoreHTTPEnvironment: CodableStoreEnvironment {
    typealias SourceType = URL

    typealias GET<T: Decodable> = CodableStoreEnvironmentHTTPEndpoint<T>
    typealias POST<T: Decodable> = CodableStoreEnvironmentHTTPBodyEndpoint<T>
//    typealias GET<T> = CodableStoreEnvironmentHTTPEndpoint
////    typealias POST<IN, OUT: Decodable> = CodableStoreEnvironmentEndpoint<IN, OUT>
////    typealias PUT<IN, OUT: Decodable> = CodableStoreEnvironmentEndpoint<IN, OUT>
////    typealias DELETE<IN, OUT: Decodable> = CodableStoreEnvironmentEndpoint<IN, OUT>
}

extension CodableStoreHTTPEnvironment {
    static func request<T>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> ProviderRequestType {
        let source = sourceBase.appending(endpoint.path)
        let request = URLRequest(url: source)

        if let endpoint = endpoint as? CodableStoreEnvironmentHTTPEndpoint<T> {
            return endpoint.getRequest(url: source)
        }
//
        return request
    }
}

extension CodableStore {
    func send<T>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> Promise<T?> {
        let request = environment.request(endpoint)
        return send(request)
    }
}







