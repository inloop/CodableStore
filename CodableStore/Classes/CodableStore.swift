//
//  CodableStore.swift
//  Pods
//
//  Created by Jakub Knejzlik on 12/02/2018.
//

import Foundation
import PromiseKit


protocol CodableStoreResponse {}

public protocol CodableStoreProvider {

    associatedtype KeyType

    func read<T: Decodable>(_ key: KeyType) -> Promise<T?>
    func create<T: Encodable, U: Decodable>(_ item: T, for key: KeyType) -> Promise<U?>
}

public class CodableStore<P: CodableStoreProvider> {
    private let provider: P

    init(provider: P) {
        self.provider = provider
    }

    public func read<T: Decodable>(_ key: P.KeyType) -> Promise<T?> {
        return provider.read(key)
    }

    public func create<T: Encodable, U: Decodable>(_ item: T, for key: P.KeyType) -> Promise<U?> {
        return provider.create(item, for: key)
    }
}

extension Decodable {
    public static func read<P: CodableStoreProvider>(_ provider: P, key: P.KeyType) -> Promise<Self?> {
        return provider.read(key)
    }
}

extension Encodable {
    public func create<P: CodableStoreProvider, U: Decodable>(_ provider: P, key: P.KeyType) -> Promise<U?> {
        return provider.create(self, for: key)
    }
}
