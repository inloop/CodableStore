//
//  CodableStoreRequest.swift
//  CodableStore
//
//  Created by Jakub Knejzlik on 12/10/2018.
//

import Foundation

public class CodableStoreRequest<T: Decodable,E: CodableStoreEnvironment> {
    let source: E.SourceType
    let request: E.ProviderRequestType
    private let adapters: [CodableStoreAdapter<E>]
    
    init(source: E.SourceType, request: E.ProviderRequestType, adapters: [CodableStoreAdapter<E>] = []) {
        self.source = source
        self.request = request
        self.adapters = adapters
    }

    public func send<U: CodableStoreEnvironmentEndpoint<T>>(_ handler: @escaping (U.ResultType?, Error?) -> Void) {
        self.source.send(self.request) { (result: E.ProviderResponseType?, error: Error?) in
            do {
                if let error = error {
                    throw error
                }
                guard let result = result, error == nil else {
                    return handler(nil, error)
                }

                let resultResult: E.ProviderResponseType = self.adapters.reduce(result, { (value: E.ProviderResponseType, nextAdapter: CodableStoreAdapter<E>) in
                    return nextAdapter.transform(response: value)
                })
                let deserialized: U.ResultType = try resultResult.deserialize()
                handler(deserialized, nil)
            } catch {
                do{
                    let result = try self.recoverWithAdapters(error)
                    handler(result, nil)
                } catch {
                    handler(nil, error)
                }
            }
        }
    }

    private func recoverWithAdapters<U: CodableStoreEnvironmentEndpoint<T>>(_ error: Error) throws -> U.ResultType {
        for adapter in adapters {
            if let result: T = try adapter.handle(error: error) {
                return result
            }
        }
        throw error
    }
}
