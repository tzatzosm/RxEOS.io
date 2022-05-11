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
    
    private let measurementFormatter: MeasurementFormatter = {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        return measurementFormatter
    }()
    
    private let apiService: AnyAPIService
    
    init(apiService: AnyAPIService) {
        self.apiService = apiService
    }
    
    func transform(input: Input) -> Output {
        let getAccount = input.searchClick
            .withLatestFrom(input.searchInput)
            .flatMap { apiService.getAccount(accountName: $0).materialize() }
            .share()
        
        let getAccountResponse = getAccount.compactMap(\.element)
        let getAccountResponseError = getAccount.map(\.error)
        
        let defaultValue = "-"
        
        let eosBalance = composeValueOrError(
            value: getAccountResponse.map(\.coreLiquidBalance),
            error: getAccountResponseError,
            defaultValue: defaultValue)
        let cpuLimit = makeLimit(
            limit: getAccountResponse.map(\.cpuLimit),
            error: getAccountResponseError,
            unit: .just(UnitDuration.microseconds),
            defaultUnit: UnitDuration.microseconds)
        let netLimit = makeLimit(
            limit: getAccountResponse.map(\.netLimit),
            error: getAccountResponseError,
            unit: .just(UnitInformationStorage.bytes),
            defaultUnit: UnitInformationStorage.bytes)
        let ram = makeRam(response: getAccountResponse, error: getAccountResponseError)
        return .init(eosBalance: eosBalance, cpu: cpuLimit, net: netLimit, ram: ram)
    }
    
    private func makeRam(
        response: Observable<GetAccountResponseDTO>,
        error: Observable<Error?>
    ) -> Output.RamUsage {
        let quota = composeMeasurementValueOrError(
            value: response.map(\.ramQuota),
            error: error,
            defaultValue: "-",
            unit: .just(UnitInformationStorage.bytes),
            defaultUnit: UnitInformationStorage.bytes)
        
        let usage = composeMeasurementValueOrError(
            value: response.map(\.ramUsage),
            error: error,
            defaultValue: "-",
            unit: .just(UnitInformationStorage.bytes),
            defaultUnit: UnitInformationStorage.bytes)
        
        return .init(quota: quota, usage: usage)
    }
    
    private func makeCPULimit(
        cpuLimit: Observable<GetAccountLimitDTO>,
        error: Observable<Error?>
    ) -> Output.ResourceLimit {
        let max = composeMeasurementValueOrError(
            value: cpuLimit.map(\.max),
            error: error,
            defaultValue: "-",
            unit: .just(UnitDuration.microseconds),
            defaultUnit: UnitDuration.microseconds)
        let available = composeMeasurementValueOrError(
            value: cpuLimit.map(\.available),
            error: error,
            defaultValue: "-",
            unit: .just(UnitDuration.microseconds),
            defaultUnit: UnitDuration.microseconds)
        let used = composeMeasurementValueOrError(
            value: cpuLimit.map(\.used),
            error: error,
            defaultValue: "-",
            unit: .just(UnitDuration.microseconds),
            defaultUnit: UnitDuration.microseconds)
        return .init(max: max, available: available, used: used)
    }
    
    private func makeLimit<T: Dimension>(
        limit: Observable<GetAccountLimitDTO>,
        error: Observable<Error?>,
        unit: Observable<T>,
        defaultUnit: T
    ) -> Output.ResourceLimit {
        let max = composeMeasurementValueOrError(
            value: limit.map(\.max),
            error: error,
            defaultValue: "-",
            unit: unit,
            defaultUnit: defaultUnit)
        let available = composeMeasurementValueOrError(
            value: limit.map(\.available),
            error: error,
            defaultValue: "-",
            unit: unit,
            defaultUnit: defaultUnit)
        let used = composeMeasurementValueOrError(
            value: limit.map(\.used),
            error: error,
            defaultValue: "-",
            unit: unit,
            defaultUnit: defaultUnit)
        return .init(max: max, available: available, used: used)
    }
    
    private func composeMeasurementValueOrError<T: Dimension>(
        value: Observable<Int>,
        error: Observable<Error?>,
        defaultValue: String,
        unit: Observable<T>,
        defaultUnit: T
    ) -> Driver<String> {
        let value = Observable
            .combineLatest(value.map(Double.init), unit)
            .map { used, unit -> String in
                let measurement = Measurement(value: used, unit: defaultUnit).converted(to: unit)
                let string = measurementFormatter.string(from: measurement)
                return string
            }
        let errorValue = error.compactMap { $0 }.map { _ in defaultValue }
        return Observable.merge(value, errorValue).asDriver(onErrorJustReturn: defaultValue)
    }
    
    private func composeValueOrError<T>(
        value: Observable<T>,
        error: Observable<Error?>,
        defaultValue: T) -> Driver<T> {
            let value = value.startWith(defaultValue)
            let errorValue = error.compactMap { $0 }.map { _ in defaultValue }
            return Observable.merge(value, errorValue).asDriver(onErrorJustReturn: defaultValue)
    }
}

