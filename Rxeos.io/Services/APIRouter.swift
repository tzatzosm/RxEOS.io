//
//  APIRouter.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation

enum APIRouter: URLRequestConvertible {
    var path: String {
        return "/v1/chain/get_account"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var body: Data? {
        if case let .getAccount(accountName) = self {
            let request = GetAccountRequestDTO(accountName: accountName)
            return try? JSONEncoder.camelCaseEncoder.encode(request)
        }
        return nil
    }
    
    case getAccount(accountName: String)
}
