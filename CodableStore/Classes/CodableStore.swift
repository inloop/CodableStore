//
//  CodableStore.swift
//  Pods
//
//  Created by Jakub Knejzlik on 12/02/2018.
//

import Foundation
import PromiseKit

public protocol CodableStoreSource {
    func get<T: Decodable>() -> Promise<T?>
    func set<T: Encodable, U: Decodable>(_ item: T) -> Promise<U?>
}

public protocol CodableStoreProvider {

    associatedtype KeyType

    func get<T: Decodable>(_ key: KeyType) -> Promise<T?>
    func set<T: Encodable, U: Decodable>(_ item: T, for key: KeyType) -> Promise<U?>
}

public class CodableStore<P: CodableStoreProvider> {

    private let provider: P

    init(provider: P) {
        self.provider = provider
    }

    public func get<T: Decodable>(_ key: P.KeyType) -> Promise<T?> {
        return provider.get(key)
    }

    public func set<T: Encodable, U: Decodable>(_ item: T, for key: P.KeyType) -> Promise<U?> {
        return provider.set(item, for: key)
    }
}

extension Decodable {
    public static func get<S: CodableStoreSource>(_ source: S) -> Promise<Self?> {
        return source.get()
    }
}

extension Encodable {
    public func set<S: CodableStoreSource, U: Decodable>(_ source: S) -> Promise<U?> {
        return source.set(self)
    }
}
