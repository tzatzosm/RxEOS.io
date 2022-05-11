//
//  AnyAPIService.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation
import RxSwift

protocol AnyAPIService {
    func getAccount(accountName: String) -> Observable<GetAccountResponseDTO>
}
