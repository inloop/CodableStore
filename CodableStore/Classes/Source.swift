//
//  Environment.swift
//  Pods
//
//  Created by Jakub Knejzlik on 23/02/2018.
//

import Foundation

public protocol CodableStoreSource {

    associatedtype Provider: CodableStoreProvider

    func get(_ handler: @escaping Provider.ResponseHandler) -> Void
    func set(_ item: Encodable,_ handler: @escaping Provider.ResponseHandler) -> Void
    func send(_ request: Provider.RequestType, _ handler: @escaping Provider.ResponseHandler)

    func appending(_ path: String) -> Self
}

extension String: CodableStoreSource {

    public typealias Provider = UserDefaults

    public func get(_ handler: @escaping Provider.ResponseHandler) {
        let request = UserDefaultsCodableStoreRequest(method: .get, key: self)
        self.send(request, handler)
    }

    public func set(_ item: Encodable, _ handler: @escaping Provider.ResponseHandler) {
        let request = UserDefaultsCodableStoreRequest(method: .set(item), key: self)
        self.send(request, handler)
    }

    public func send(_ request: Provider.RequestType, _ handler: @escaping Provider.ResponseHandler) {
        UserDefaults.standard.send(request, handler)
    }
}

extension URL: CodableStoreSource {

    public typealias Provider = URLSession

    public func get(_ handler: @escaping Provider.ResponseHandler) {
        let request = URLRequest(url: self)
        self.send(request, handler)
    }

    public func set(_ item: Encodable, _ handler: @escaping Provider.ResponseHandler) {
        do {
            let request = try item.getURLRequest(url: self, method: "POST")
            self.send(request, handler)
        } catch {
            handler(nil, error)
        }
    }

    public func send(_ request: Provider.RequestType, _ handler: @escaping Provider.ResponseHandler) {
        URLSession.shared.send(request, handler)
    }

    public func appending(_ path: String) -> URL {
        return self.appendingPathComponent(path)
    }
}
