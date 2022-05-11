//
//  APIError.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation

enum APIError: Error, Equatable {
    case invalidStatusCode(code: Int)
}
