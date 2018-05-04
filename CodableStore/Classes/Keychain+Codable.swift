//  Copyright © 2018 INLOOPX. All rights reserved.

import Foundation

public struct Keychain: KeyedStoreProvider {
    public typealias RequestType = KeyedStoreRequest
    public typealias ResponseType = KeyedStoreResponse

    public let identifier: String

    private var container: [String: Data] {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: identifier,
            kSecReturnData: kCFBooleanTrue,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        let dataTypeRef = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)
        let status = SecItemCopyMatching(query, dataTypeRef)
        guard status == noErr,
            let data = dataTypeRef.pointee as? Data,
            let container: [String: Data] = try? data.deserialize() else { return [:] }
        return container
    }

    private func save(container: [String: Data]) {
        guard let data: Data = try? container.serialize() else { return }
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: identifier,
            kSecValueData: data
        ] as CFDictionary

        SecItemDelete(query)
        SecItemAdd(query, nil)
    }

    public func data(forKey key: String) -> Data? {
        return container[key]
    }

    public func set(data: Data, forKey key: String) {
        var container = self.container
        container[key] = data
        save(container: container)
    }
}
