//
//  Environment+HTTP.swift
//  CodableStore
//
//  Created by Jakub Knejzlik on 27/02/2018.
//

import Foundation

public enum CodableStoreEnvironmentHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public class CodableStoreEnvironmentHTTPEndpoint<T: Decodable>: CodableStoreEnvironmentEndpoint<T> {

    var method: CodableStoreEnvironmentHTTPMethod
    public var query: [String: String]? = nil
    @discardableResult public func query(_ query: [String: String]) -> Self {
        self.query = query
        return self
    }

    @discardableResult public func setQueryValue(_ value: String, forKey key: String) -> Self {
        var _query = query ?? [:]
        _query[key] = value
        self.query = _query
        return self
    }

    public init(_ method: CodableStoreEnvironmentHTTPMethod, _ path: String) {
        self.method = method
        super.init(path)
    }

    func getRequest(url: URL) -> URLRequest {

        var components = URLComponents(url: url.appending(path), resolvingAgainstBaseURL: true)!

        if let query = query {
            var queryItems = [URLQueryItem]()
            for (key,value) in query {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            components.queryItems = queryItems
        }

        var request = URLRequest(url: components.url!)
        request.httpMethod = self.method.rawValue
        return request
    }
}

public class CodableStoreEnvironmentHTTPPayloadEndpoint<U: Encodable, T: Decodable>: CodableStoreEnvironmentHTTPEndpoint<T> {
    public var body: U? = nil
    @discardableResult public func body(body: U) -> Self {
        self.body = body
        return self
    }

    override func getRequest(url: URL) -> URLRequest {
        var request = super.getRequest(url: url)
        do {
            request.httpBody = try body?.serialize()
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {}
        return request
    }
}


public protocol CodableStoreHTTPEnvironment: CodableStoreEnvironment where SourceType == URL {

    typealias Endpoint = CodableStoreEnvironmentHTTPEndpoint
    typealias EndpointWithPayload = CodableStoreEnvironmentHTTPPayloadEndpoint
}


extension CodableStoreHTTPEnvironment {

    public static func GET<T>(_ path: String) -> CodableStoreEnvironmentHTTPEndpoint<T> {
        return CodableStoreEnvironmentHTTPEndpoint(.get, path)
    }
    public static func POST<U,T>(_ path: String) -> CodableStoreEnvironmentHTTPPayloadEndpoint<U,T> {
        return CodableStoreEnvironmentHTTPPayloadEndpoint(.post, path)
    }
    public static func PUT<U,T>(_ path: String) -> CodableStoreEnvironmentHTTPPayloadEndpoint<U,T> {
        return CodableStoreEnvironmentHTTPPayloadEndpoint(.put, path)
    }
    public static func PATCH<U,T>(_ path: String) -> CodableStoreEnvironmentHTTPPayloadEndpoint<U,T> {
        return CodableStoreEnvironmentHTTPPayloadEndpoint(.patch, path)
    }
    public static func DELETE<T>(_ path: String) -> CodableStoreEnvironmentHTTPEndpoint<T> {
        return CodableStoreEnvironmentHTTPEndpoint(.delete, path)
    }

    public static func request<T>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> ProviderRequestType {
        let source = sourceBase.appending(endpoint.path)
        let request = URLRequest(url: source)

        if let endpoint = endpoint as? CodableStoreEnvironmentHTTPEndpoint<T> {
            return endpoint.getRequest(url: sourceBase)
        }
        return request
    }
}
