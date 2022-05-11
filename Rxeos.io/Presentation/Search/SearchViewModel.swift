//
//  SearchViewModel.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation
import RxSwift
import RxCocoa

struct SearchViewModel: AnyViewModel {
    struct Input {
        var searchInput: Observable<String>
        var searchClick: Observable<()>
    }
    struct Output {
        var eosBalance: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let eosBalance = input.searchClick
            .withLatestFrom(input.searchInput)
            .asDriver(onErrorJustReturn: "-")
        return .init(eosBalance: eosBalance)
    }
}
