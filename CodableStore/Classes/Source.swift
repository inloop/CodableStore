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

    func send(_ request: Provider.RequestType) -> Promise<Provider.ResponseType>

    func appending(_ path: String) -> Self
}

extension String: CodableStoreSource {

    public typealias Provider = UserDefaults

    public func get<T>() -> Promise<T?> where T : Decodable {
        let request = KeyedStoreRequest.get(key: self)
        return UserDefaults.standard.send(request).then { response -> T? in
            return try response.data?.deserialize()
        }
    }

    public func set<T: Encodable, U: Decodable>(_ item: T) -> Promise<U?> {
        let request = KeyedStoreRequest.set(key: self, value: item)
        return UserDefaults.standard.send(request).then { response -> U? in
            let res: U =  try response.data!.deserialize()
            return res
        }
    }

    public func send(_ request: KeyedStoreRequest) -> Promise<UserDefaults.ResponseType> {
        return UserDefaults.standard.send(request)
    }
}

extension URL: CodableStoreSource {

    public typealias Provider = URLSession

    public func send(_ request: URLRequest) -> Promise<URLSession.ResponseType> {
        return URLSession.shared.send(request)
    }

    public func get<T>() -> Promise<T?> where T : Decodable {
        let request = URLRequest(url: self)
        return URLSession.shared.send(request).then { response -> T? in
            return try response.deserialize()
        }
    }

    public func set<T, U>(_ item: T) -> Promise<U?> where T : Encodable, U : Decodable {
        do {
            let request = try item.getURLRequest(url: self, method: "POST")
            return URLSession.shared.send(request).then { response -> U? in
                return try response.deserialize()
            }
        } catch {
            return Promise(error: error)
        }
    }

    public func appending(_ path: String) -> URL {
        return self.appendingPathComponent(path)
    }
}
