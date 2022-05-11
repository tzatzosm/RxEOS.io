//
//  URLRequestConvertible.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation

enum HTTPMethod: String {
    case get
    case post
    case put
    case patch
    case delete
}

enum URLError: Swift.Error {
    case badURL
}

protocol URLRequestConvertible {
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Data? { get }
    
    func asURLRequest(baseUrl: String) throws -> URLRequest
}

extension URLRequestConvertible {
    func asURLRequest(baseUrl: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseUrl)\(path)") else {
            throw URLError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        return request
    }
}

