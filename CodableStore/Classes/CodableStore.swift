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

    func read<T: Decodable>(key: KeyType) -> Promise<T?>
    func create<T: Encodable, U: Decodable>(_ item: T, for key: KeyType) -> Promise<U?>
}

public class CodableStore<P: CodableStoreProvider> {
    private let provider: P

    init(provider: P) {
        self.provider = provider
    }

    public func read<T: Decodable>(_ key: P.KeyType) -> Promise<T?> {
        return provider.read(key: key)
    }

    public func create<T: Encodable, U: Decodable>(_ item: T, for key: P.KeyType) -> Promise<U?> {
        return provider.create(item, for: key)
    }
}

extension Decodable {
    public static func read<P>(_ store: CodableStore<P>, key: P.KeyType) -> Promise<Self?> {
        return store.read(key)
    }
}

extension Encodable {
    public func create<P, U: Decodable>(_ store: CodableStore<P>, key: P.KeyType) -> Promise<U?> {
        return store.create(self, for: key)
    }
}
