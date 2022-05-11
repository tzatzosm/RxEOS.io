//
//  EosSearchInputValidator.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation

struct EOSSearchInputValidator: AnyInputValidator {
    func validate(input: String) -> Bool {
        let pattern = #"[a-z1-5\.]{1,12}"#
        return input.range(of: pattern, options: .regularExpression) != nil
    }
}
