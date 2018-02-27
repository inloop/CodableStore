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
    //    public var query: U? = nil
    //    func query(query: U) -> Self {
    //        self.query = query
    //        return self
    //    }

    init(_ method: CodableStoreEnvironmentHTTPMethod, _ path: String) {
        self.method = method
        super.init(path)
    }

    func getRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = self.method.rawValue
        return request
    }
}

public class CodableStoreEnvironmentHTTPPayloadEndpoint<U: Encodable, T: Decodable>: CodableStoreEnvironmentHTTPEndpoint<T> {
    public var body: U? = nil
    func body(body: U) -> Self {
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


public protocol CodableStoreHTTPEnvironment: CodableStoreEnvironment {
    typealias SourceType = URL

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
            return endpoint.getRequest(url: source)
        }
        return request
    }
}
