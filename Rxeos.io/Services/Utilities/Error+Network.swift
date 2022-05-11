//
//  Error+Network.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation

extension Error {
    var isNetworkError: Bool {
        return (self as NSError).code == -1020
    }
}
