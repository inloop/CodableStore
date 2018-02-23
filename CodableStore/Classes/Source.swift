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
        let request = UserDefaultsCodableStoreRequest(method: .get, key: self)
        return UserDefaults.standard.send(request)
    }

    public func set<T: Encodable, U: Decodable>(_ item: T) -> Promise<U?> {
        let request = UserDefaultsCodableStoreRequest(method: .set(item), key: self)
        return UserDefaults.standard.send(request)
    }
}

extension URL: CodableStoreSource {
    public func appending(_ path: String) -> URL {
        return self.appendingPathComponent(path)
    }

    public func get<T>() -> Promise<T?> where T : Decodable {
        let request = URLRequest(url: self)
        return URLSession.shared.send(request)
    }

    public func set<T, U>(_ item: T) -> Promise<U?> where T : Encodable, U : Decodable {
        do {
            let request = try item.getURLRequest(url: self, method: "POST")
            return URLSession.shared.send(request)
        } catch {
            return Promise(error: error)
        }
    }
}
