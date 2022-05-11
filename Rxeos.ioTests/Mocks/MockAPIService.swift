//
//  MockAPIService.swift
//  Rxeos.ioTests
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
@testable import Rxeos_io

class MockAPIService: AnyAPIService {
    
    var error: Error?
    var response: GetAccountResponseDTO?
    
    init() { }
    
    private(set) var getAccountIsCalled = false
    func getAccount(accountName: String) -> Observable<GetAccountResponseDTO> {
        XCTAssertFalse(getAccountIsCalled)
        if let error = error {
            return .error(error)
        }
        return Observable<GetAccountResponseDTO?>
            .just(response)
            .compactMap { $0 }.asObservable()
    }
}
