//
//  URLSession+Codable.swift
//  Pods
//
//  Created by Jakub Knejzlik on 14/02/2018.
//
import Foundation
import PromiseKit

extension URLRequest: CodableStoreProviderRequest {}

public enum URLSessionCodableError: Error {
    case unexpectedStatusCode(statusCode: Int)
}

struct URLSessionCodableResponse<T> {
    let data: T
    let response: URLResponse?
}

extension URLSession: CodableStoreProvider {

    public typealias RequestType = URLRequest

    public func send<T>(_ request: URLSession.RequestType) -> Promise<T?> where T : Decodable {
        return _send(request).then { $0.data }
    }

    private func _send<T: Decodable>(_ request: URLSession.RequestType) -> Promise<URLSessionCodableResponse<T>> {
        return Promise<URLSessionCodableResponse<T>> { (resolve, reject) in
            self.dataTask(with: request, completionHandler: adapter(resolve, reject)).resume()
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

private func adapter<T: Decodable>(_ resolve: @escaping (URLSessionCodableResponse<T>) -> Void, _ reject: @escaping (Error) -> Void) -> (Data?, URLResponse?, Error?) -> Void {
    return { data, response, error in
        if let error = error {
            return reject(error)
        }

        guard let data = data else {
            assertionFailure("no data")
            return
        }

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            return reject(URLSessionCodableError.unexpectedStatusCode(statusCode: httpResponse.statusCode))
        }

        do {
            if let data = data as? T {
                resolve(URLSessionCodableResponse(data: data, response: response))
            } else {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decoded = try decoder.decode(T.self, from: data)
                resolve(URLSessionCodableResponse(data: decoded, response: response))
            }
        } catch {
            reject(error)
        }
    }
}


