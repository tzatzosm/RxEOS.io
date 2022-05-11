//
//  GetAccountLimitDTO.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation

struct GetAccountLimitDTO: Decodable {
    let used: Int
    let available: Int
    let max: Int
}
