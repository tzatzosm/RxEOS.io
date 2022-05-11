//
//  MockValidator.swift
//  Rxeos.ioTests
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation
@testable import Rxeos_io

class MockValidator: AnyInputValidator {
    var isValid: Bool = true
    
    func validate(input: String) -> Bool {
        return isValid
    }
}
