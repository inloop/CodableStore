//
//  CodableStore+Promise.swift
//  CodableStore
//
//  Created by Jakub Knejzlik on 03/11/2018.
//

import Foundation
import PromiseKit

extension CodableStoreEnvironment {
    @discardableResult public static func send<T, U: CodableStoreEnvironmentEndpoint<T>>(_ endpoint: U) -> Promise<T> {
        return Promise<T> { seal in
            self.request(endpoint).send({ (response, error) in
                seal.resolve(error, response)
            })
        }
    }
}

extension CodableStore {
    @discardableResult public func send<T, U: CodableStoreEnvironmentEndpoint<T>>(_ endpoint: CodableStoreEnvironmentEndpoint<T>) -> Promise<T> {
        return Promise<T> { seal in
            let request: CodableStoreRequest<T,EnvironmentType> = self.request(endpoint)
            request.send({ (response, error) in
                seal.resolve(error, response)
            })
        }
    }
}

extension CodableStoreSource {
    public func get<T: Decodable>() -> Promise<T> {
        return Promise { seal -> Void in
            self.get { (response: Provider.ResponseType?, error) in
                guard let response = response else {
                    return seal.resolve(error, nil)
                }
                let res: T? = try? response.deserialize()
                seal.resolve(error, res)
            }
        }
    }
    public func set<T: Decodable>(_ item: Encodable) -> Promise<T> {
        return Promise<T> { seal in
            self.set(item) { (response: Provider.ResponseType?, error) in
                guard let response = response else {
                    return seal.resolve(error, nil)
                }
                let res: T? = try? response.deserialize()
                seal.resolve(error, res)
            }
        }
    }

}
