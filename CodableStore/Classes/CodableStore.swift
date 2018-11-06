//
//  CodableStore.swift
//  Pods
//
//  Created by Jakub Knejzlik on 12/02/2018.
//

import Foundation

enum CodableStoreError: Error {
    case emptyResponseData
}

public protocol CodableStoreProviderRequest {
    var debugDescription: String { get }
}
public protocol CodableStoreProviderResponse {
    var debugDescription: String { get }
    func deserialize<T: Decodable>() throws -> T
}

public protocol CodableStoreProvider {

    associatedtype RequestType: CodableStoreProviderRequest
    associatedtype ResponseType: CodableStoreProviderResponse

    typealias ResponseHandler = (ResponseType?, Error?) -> Void

    func send(_ request: RequestType, _ handler: @escaping ResponseHandler)
}

public typealias CodableStoreLoggingFn = (_ items: Any...) -> Void

public class CodableStore<E: CodableStoreEnvironment> {

    typealias EnvironmentType = E
    let environment: E.Type
    private var adapters = [CodableStoreAdapter<E>]()

    public var loggingFn: CodableStoreLoggingFn? = nil

    public init(_ environment: E.Type) {
        self.environment = environment
        #if DEBUG
            self.loggingFn = { (items: Any...) in
                print(items)
            }
        #endif
    }

    @discardableResult public func request<T: Decodable>(_ request: E.ProviderRequestType) -> CodableStoreRequest<T,E> {
        loggingFn?("[CodableStore:request]", request.debugDescription)
        let request = adapters.reduce(request, { $1.transform(request: $0) })
        return CodableStoreRequest(source: self.environment.sourceBase, request: request, adapters: adapters)
    }

    @discardableResult public func request<T:Decodable>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> CodableStoreRequest<T,E> {
        let request = self.environment.providerRequest(endpoint)
        return self.request(request)
    }

    public func addAdapter(_ adapter: CodableStoreAdapter<E>) {
        adapters.append(adapter)
    }
}

extension CodableStoreProviderRequest {
    public var debugDescription: String {
        return "unkown request (var debugDescription: String not implemented)"
    }
}
extension CodableStoreProviderResponse {
    public var debugDescription: String {
        return "unkown response (var debugDescription: String not implemented)"
    }
}
