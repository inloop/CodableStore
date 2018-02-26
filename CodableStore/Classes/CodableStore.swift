//
//  CodableStore.swift
//  Pods
//
//  Created by Jakub Knejzlik on 12/02/2018.
//

import Foundation
import PromiseKit

public protocol CodableStoreProviderRequest { }

public protocol CodableStoreProvider {

    associatedtype RequestType: CodableStoreProviderRequest
    
    func send<T: Decodable>(_ request: RequestType) -> Promise<T?>
}

public class CodableStore<E: CodableStoreEnvironment> {

    typealias EnvironmentType = E
    let environment: E.Type

    init(_ environment: E.Type) {
        self.environment = environment
    }
    
    func send<T: Decodable>(_ request: E.ProviderRequestType) -> Promise<T?> {
        return self.environment.sourceBase.send(request)
    }
}

