//
//  Adapter+NetworkStatusIndicator.swift
//  CodableStore
//
//  Created by Jakub Knejzlik on 28/03/2018.
//

import UIKit
import Foundation

final public class CodableStoreNetworkActivityIndicatorAdapter<E: CodableStoreEnvironment>: CodableStoreAdapter<E> {
    
    private var counter = 0
    public var isNetworkActivityIndicatorVisible = false

    private func updateIndicator() {
        isNetworkActivityIndicatorVisible = counter > 0
        UIApplication.shared.isNetworkActivityIndicatorVisible = isNetworkActivityIndicatorVisible
    }

    override public func transform(request: Provider.RequestType) -> Provider.RequestType {
        counter += 1
        updateIndicator()
        return request
    }
    override public func transform(response: Provider.ResponseType) -> Provider.ResponseType {
        counter -= 1
        updateIndicator()
        return response
    }
    override public func handle<T: Decodable>(error: Error) throws -> T? {
        counter -= 1
        updateIndicator()
        return nil
    }
}
