//
//  AnyAPIService.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation
import RxSwift
import RxCocoa

private let validStatusCodes = 200..<400

protocol AnyAPIService {
    func getAccount(accountName: String) -> Observable<GetAccountResponseDTO>
}

extension AnyAPIService {
    func makeRequest<T: Decodable>(
        baseUrl: String,
        request: URLRequestConvertible,
        decoder: JSONDecoder = JSONDecoder()
    ) -> Observable<T> {
        return Observable<()>.just(()).map { _ in
            try request.asURLRequest(baseUrl: baseUrl)
        }
        .flatMap { URLSession.shared.rx.response(request: $0) }
        .map { response, data in
            guard validStatusCodes.contains(response.statusCode) else {
                throw APIError.invalidStatusCode(code: response.statusCode)
            }
            return try decoder.decode(T.self, from: data)
        }
    }
}
