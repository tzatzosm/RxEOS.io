//
//  GetAccountResponseDTO.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation

struct GetAccountResponseDTO: Decodable {
    let accountName: String
    let coreLiquidBalance: String
    let cpuLimit: GetAccountLimitDTO
    let netLimit: GetAccountLimitDTO
    let ramQuota: Int
    let ramUsage: Int
}
