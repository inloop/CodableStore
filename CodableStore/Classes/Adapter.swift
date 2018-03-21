//
//  Adapter.swift
//  CodableStore
//
//  Created by Jakub Knejzlik on 09/03/2018.
//

import Foundation

open class CodableStoreAdapter<E: CodableStoreEnvironment> {

    public init() { }

    public typealias Provider = E.SourceType.Provider

    open func transform(request: Provider.RequestType) -> Provider.RequestType {
        return request
    }
    open func transform(response: Provider.ResponseType) -> Provider.ResponseType {
        return response
    }
    open func handle<T: Decodable>(error: Error) throws -> T? {
        return nil
    }
}

