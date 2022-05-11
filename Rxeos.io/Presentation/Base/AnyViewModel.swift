//
//  AnyViewModel.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation

protocol AnyViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
