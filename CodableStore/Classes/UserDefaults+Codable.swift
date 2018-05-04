//
//  UserDefaults+Codable.swift
//  Pods
//
//  Created by Jakub Knejzlik on 12/02/2018.
//

import PromiseKit

extension UserDefaults: KeyedStoreProvider {
    public typealias RequestType = KeyedStoreRequest
    public typealias ResponseType = KeyedStoreResponse

    public func set(data: Data, forKey key: String) {
        set(data, forKey: key)
    }
}
