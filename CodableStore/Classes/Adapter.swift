//
//  Adapter.swift
//  CodableStore
//
//  Created by Jakub Knejzlik on 09/03/2018.
//

import Foundation

public class CodableStoreAdapter<E: CodableStoreEnvironment> {

    typealias Provider = E.SourceType.Provider

    func transform(request: Provider.RequestType) -> Provider.RequestType {
        return request
    }
    func transform(response: Provider.ResponseType) -> Provider.ResponseType {
        return response
    }
    func handle<T: Decodable>(error: Error) throws -> T? {
        return nil
    }
}

