//
//  CodableStore.swift
//  Pods
//
//  Created by Jakub Knejzlik on 12/02/2018.
//

import Foundation
import PromiseKit

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
    
    func send(_ request: RequestType) -> Promise<ResponseType>
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
    
    public func send<T: Decodable>(_ request: E.ProviderRequestType) -> Promise<T?> {
        loggingFn?("[CodableStore:request]", request.debugDescription)
        let request = adapters.reduce(request, { $1.transform(request: $0) })
        return self.environment.sourceBase.send(request).then { response in
            return self.adapters.reduce(response, { $1.transform(response: $0) })
        }.then { response -> T in
            return try response.deserialize()
        }.recover(execute: { (error) -> T? in
            // we want to iterate adapters and retrieve result from error handler
            for adapter in self.adapters {
                return try adapter.handle(error: error)
            }
            throw error
        })
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
