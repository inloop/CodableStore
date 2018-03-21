//
//  Adapter+Logging.swift
//  CodableStore
//
//  Created by Jakub Knejzlik on 21/03/2018.
//

import Foundation

final public class CodableStoreLoggingAdapter<E: CodableStoreEnvironment>: CodableStoreAdapter<E> {

    public typealias LoggingFn = (_ items: Any...) -> Void

    public var loggingFn: LoggingFn

    public init(loggingFn: LoggingFn? = nil) {
        self.loggingFn = loggingFn ?? { (items: Any...) in
            print(items)
        }
    }

    override public func transform(request: Provider.RequestType) -> Provider.RequestType {
        self.loggingFn("[CodableStore:request]", request.debugDescription)
        return request
    }
    override public func transform(response: Provider.ResponseType) -> Provider.ResponseType {
        self.loggingFn("[CodableStore:response]", response.debugDescription)
        return response
    }
    override public func handle<T: Decodable>(error: Error) throws -> T? {
        self.loggingFn("[CodableStore:error]", error.localizedDescription)
        return nil
    }
}
