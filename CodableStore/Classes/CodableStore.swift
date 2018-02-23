//
//  CodableStore.swift
//  Pods
//
//  Created by Jakub Knejzlik on 12/02/2018.
//

import Foundation
import PromiseKit

public protocol CodableStoreProvider {

    associatedtype KeyType

    func get<T: Decodable>(_ key: KeyType) -> Promise<T?>
    func set<T: Encodable, U: Decodable>(_ item: T, for key: KeyType) -> Promise<U?>
}

public protocol CodableStoreEnvironment {
    static var sourceBase: CodableStoreSource { get }

    typealias Get<T: Decodable> = CodableStore<Self>.GetEndpoint<T>
    typealias Set<T: Encodable, U: Decodable> = CodableStore<Self>.SetEndpoint<T, U>
}

public protocol CodableStoreCrudEnvironment {
    static var sourceBase: CodableStoreSource { get }
}

public class CodableStore<E: CodableStoreEnvironment> {
    let environment: E.Type

    init(_ environment: E.Type) {
        self.environment = environment
    }

    func get<T>(from: CodableStore.GetEndpoint<T>) -> Promise<T?> {
        let sourceWithPath = self.environment.sourceBase.appending(from.path)
        return sourceWithPath.get()
    }

    func set<T, U>(_ item: T, in endpoint: CodableStore.SetEndpoint<T,U>) -> Promise<U?> {
        let sourceWithPath = self.environment.sourceBase.appending(endpoint.path)
        return sourceWithPath.set(item)
    }
}

extension CodableStore {
    public struct GetEndpoint<T: Decodable> {
        let path: String

        public init(_ path: String) {
            self.path = path
        }
    }

    public struct SetEndpoint<T: Encodable, U: Decodable> {
        let path: String

        public init(_ path: String) {
            self.path = path
        }
    }
}

extension CodableStore.GetEndpoint: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
extension CodableStore.SetEndpoint: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
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
