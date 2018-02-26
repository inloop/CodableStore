//
//  Environment.swift
//  Pods
//
//  Created by Jakub Knejzlik on 23/02/2018.
//

import Foundation
import PromiseKit

public protocol CodableStoreSource {

    associatedtype Provider: CodableStoreProvider

    func send<T: Decodable>(_ request: Provider.RequestType) -> Promise<T?>

    func appending(_ path: String) -> Self
}

extension String: CodableStoreSource {
    public typealias Provider = UserDefaults

    public func get<T>() -> Promise<T?> where T : Decodable {
        let request = UserDefaultsCodableStoreRequest(method: .get, key: self)
        return UserDefaults.standard.send(request)
    }

    public func set<T: Encodable, U: Decodable>(_ item: T) -> Promise<U?> {
        let request = UserDefaultsCodableStoreRequest(method: .set(item), key: self)
        return UserDefaults.standard.send(request)
    }

    public func send<T>(_ request: String.Provider.RequestType) -> Promise<T?> where T : Decodable {
        return UserDefaults.standard.send(request)
    }
}

extension URL: CodableStoreSource {
    public typealias Provider = URLSession

    public func send<T>(_ request: URLRequest) -> Promise<T?> where T : Decodable {
        return URLSession.shared.send(request)
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

    public func appending(_ path: String) -> URL {
        return self.appendingPathComponent(path)
    }
}
