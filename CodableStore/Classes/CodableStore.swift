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

public protocol CodableStoreProvider {

    associatedtype RequestType: CodableStoreProviderRequest
    
    func send<T: Decodable>(_ request: RequestType) -> Promise<T?>
}

public typealias CodableStoreLoggingFn = (_ items: Any...) -> Void

public class CodableStore<E: CodableStoreEnvironment> {

    typealias EnvironmentType = E
    let environment: E.Type

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
        return self.environment.sourceBase.send(request)
    }
}

extension CodableStoreProviderRequest {
    public var debugDescription: String {
        return "unkown request (var debugDescription: String not implemented)"
    }
}
