//
//  DefaultAPIService.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation
import RxSwift
import RxCocoa

struct DefaultAPIService: AnyAPIService {
    
    private let baseURL: String
    private let decoder: JSONDecoder
    
    init(baseUrl: String, decoder: JSONDecoder) {
        self.decoder = decoder
        self.baseURL = baseUrl
    }
    
    func getAccount(accountName: String) -> Observable<GetAccountResponseDTO> {
        return makeRequest(
            baseUrl: baseURL,
            request: APIRouter.getAccount(accountName: accountName),
            decoder: decoder)
    }
    
}

