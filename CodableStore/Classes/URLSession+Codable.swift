//
//  URLSession+Codable.swift
//  Pods
//
//  Created by Jakub Knejzlik on 14/02/2018.
//
import Foundation
import PromiseKit

extension URLRequest: CodableStoreProviderRequest {
    public var debugDescription: String {
        var curl = String(format: "curl -v -X %@", httpMethod ?? "UNKNOWN")

        if let url = url {
            curl.append(" '\(url.absoluteString)'")
        }

        allHTTPHeaderFields?.forEach({ (item) in
            curl.append(" -H '\(item.key): \(item.value)'")
        })

        if let body = httpBody, let bodyString = String.init(data: body, encoding: .utf8) {
            curl.append(" -d '\(bodyString)'")
        }

        return curl
    }
}

public enum URLSessionCodableError: Error {
    case unexpectedError(error: Error)
    case unexpectedStatusCode(response: UnexpectedStatusCodeResponse)
}

public struct UnexpectedStatusCodeResponse {
    public let statusCode: Int
    public let response: HTTPURLResponse
    public let data: Data

    public func decodeData<T: Decodable>() -> T? {
        return try? data.deserialize()
    }
}

public struct URLSessionCodableResponse: CodableStoreProviderResponse {
    let data: Data?
    let response: URLResponse?

    public var debugDescription: String {
        if let data = data, let res = String(data: data, encoding: .utf8) {
            return res
        }
        return "empty response"
    }

    public func deserialize<T>() throws -> T where T : Decodable {
        guard let data = data else {
            fatalError("empty response data")
        }
        return try data.deserialize()
    }
}

extension URLSession: CodableStoreProvider {

    public typealias RequestType = URLRequest
    public typealias ResponseType = URLSessionCodableResponse

    public func send(_ request: URLRequest) -> Promise<URLSession.ResponseType> {
        return _send(request)
    }

    private func _send(_ request: URLSession.RequestType) -> Promise<URLSessionCodableResponse> {
        return Promise<URLSessionCodableResponse> { (resolve, reject) in
            self.dataTask(with: request, completionHandler: HTTPResponsePromiseHandler(resolve, reject)).resume()
        }
    }
}

extension Encodable {
    func getURLRequest(url: URL, method: String) throws -> URLRequest {
        var request = URLRequest(url: url)

        request.httpBody = try self.serialize()
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = method

        return request
    }
}

private func HTTPResponsePromiseHandler(_ resolve: @escaping (URLSessionCodableResponse) -> Void, _ reject: @escaping (URLSessionCodableError) -> Void) -> (Data?, URLResponse?, Error?) -> Void {
    return { data, response, error in
        if let error = error {
            return reject(URLSessionCodableError.unexpectedError(error: error))
        }

        guard let data = data else {
            assertionFailure("no data")
            return
        }

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            let errorResponse = UnexpectedStatusCodeResponse(statusCode: httpResponse.statusCode, response: httpResponse, data: data)
            return reject(URLSessionCodableError.unexpectedStatusCode(response: errorResponse))
        }

        resolve(URLSessionCodableResponse(data: data, response: response))
    }
}
