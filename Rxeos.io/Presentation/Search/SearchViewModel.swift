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
        
        struct ResourceLimit {
            let max: Driver<String>
            let available: Driver<String>
            let used: Driver<String>
        }
        
        struct RamUsage {
            let quota: Driver<String>
            let usage: Driver<String>
        }
        
        let eosBalance: Driver<String>
        let cpu: ResourceLimit
        let net: ResourceLimit
        let ram: RamUsage
    }
    
    func transform(input: Input) -> Output {
        let eosBalance = input.searchClick
            .withLatestFrom(input.searchInput)
            .asDriver(onErrorJustReturn: "-")
        let cpuLimit = makeCPULimit()
        let netLimit = makeNetLimit()
        let ramUsage = makeRamUsage()
        return .init(eosBalance: eosBalance, cpu: cpuLimit, net: netLimit, ram: ramUsage)
    }
    
    private func makeRamUsage() -> Output.RamUsage {
        return .init(quota: .just("-"), usage: .just("-"))
    }
    
    private func makeCPULimit() -> Output.ResourceLimit {
        return .init(max: .just("-"), available: .just("-"), used: .just("-"))
    }
    
    private func makeNetLimit() -> Output.ResourceLimit {
        return .init(max: .just("-"), available: .just("-"), used: .just("-"))
    }
}
