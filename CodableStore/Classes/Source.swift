//
//  Environment.swift
//  Pods
//
//  Created by Jakub Knejzlik on 23/02/2018.
//

import Foundation
import PromiseKit

public protocol CodableStoreSource {
    func get<T: Decodable>() -> Promise<T?>
    func set<T: Encodable, U: Decodable>(_ item: T) -> Promise<U?>

    func appending(_ path: String) -> Self
}

extension String: CodableStoreSource {
    public func get<T>() -> Promise<T?> where T : Decodable {
        return UserDefaults.standard.get(self)
    }

    public func set<T, U>(_ item: T) -> Promise<U?> where T : Encodable, U : Decodable {
        return UserDefaults.standard.set(item, for: self)
    }
}

extension URL: CodableStoreSource {
    public func appending(_ path: String) -> URL {
        return self.appendingPathComponent(path)
    }

    public func get<T>() -> Promise<T?> where T : Decodable {
        return URLSession.shared.get(self)
    }

    public func set<T, U>(_ item: T) -> Promise<U?> where T : Encodable, U : Decodable {
        return URLSession.shared.set(item, for: self)
    }
}
