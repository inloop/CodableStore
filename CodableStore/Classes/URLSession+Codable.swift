//
//  URLSession+Codable.swift
//  Pods
//
//  Created by Jakub Knejzlik on 14/02/2018.
//
import Foundation

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

    public func decodeData<T: Decodable>() throws -> T {
        return try data.deserialize()
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
            throw CodableStoreError.emptyResponseData
        }
        return try data.deserialize()
    }
}

extension URLSession: CodableStoreProvider {

    public typealias RequestType = URLRequest
    public typealias ResponseType = URLSessionCodableResponse

    public func send(_ request: RequestType, _ handler: @escaping ResponseHandler) {
        var task: URLSessionDataTask? = nil
        task = self.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                return handler(nil, URLSessionCodableError.unexpectedError(error: error))
            }

            guard let data = data else {
                assertionFailure("no data")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
                let errorResponse = UnexpectedStatusCodeResponse(statusCode: httpResponse.statusCode, response: httpResponse, data: data)
                return handler(nil, URLSessionCodableError.unexpectedStatusCode(response: errorResponse))
            }

            let response = URLSessionCodableResponse(data: data, response: response)
            handler(response, nil)
        })
        task?.resume()
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
