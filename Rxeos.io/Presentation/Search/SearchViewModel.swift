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
        let ramStorageUnit: Observable<UnitInformationStorage>
        let cpuDurationUnit: Observable<UnitDuration>
        let netStorageUnit: Observable<UnitInformationStorage>
    }
    
    struct Output {
        
        struct ResourceLimit {
            let max: Driver<String>
            let available: Driver<String>
            let used: Driver<String>
            let unit: Driver<String>
        }
        
        struct RamUsage {
            let quota: Driver<String>
            let usage: Driver<String>
            let unit: Driver<String>
        }
        
        let errorMessage: Driver<String?>
        let eosBalance: Driver<String>
        let cpu: ResourceLimit
        let net: ResourceLimit
        let ram: RamUsage
        let availableDurationUnits: Driver<[UnitDuration]>
        let availableInformationStorageUnits: Driver<[UnitInformationStorage]>
    }
    
    private let measurementFormatter: MeasurementFormatter = {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        return measurementFormatter
    }()
    
    private let apiService: AnyAPIService
    
    private let availableDurationUnits = Driver.just([
        UnitDuration.microseconds,
        UnitDuration.milliseconds,
        UnitDuration.seconds,
        UnitDuration.minutes,
        UnitDuration.hours])
    
    private let availableInformationsStorageUnits = Driver.just([
        UnitInformationStorage.bytes,
        UnitInformationStorage.kilobytes,
        UnitInformationStorage.megabytes,
        UnitInformationStorage.gigabytes,
        UnitInformationStorage.terabytes])
    
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
        
        let errorMessage = formatError(error: getAccountResponseError).startWith(nil).debug()
        
        let defaultValue = "-"
        
        let eosBalance = composeValueOrError(
            value: getAccountResponse.map(\.coreLiquidBalance),
            error: getAccountResponseError,
            defaultValue: defaultValue)
        let cpuLimit = makeLimit(
            limit: getAccountResponse.map(\.cpuLimit),
            error: getAccountResponseError,
            unit: input.cpuDurationUnit,
            defaultUnit: .microseconds,
            defaultValue: "-")
        let netLimit = makeLimit(
            limit: getAccountResponse.map(\.netLimit),
            error: getAccountResponseError,
            unit: input.netStorageUnit,
            defaultUnit: .bytes,
            defaultValue: "-")
        let ram = makeRam(
            response: getAccountResponse,
            error: getAccountResponseError,
            unit: input.ramStorageUnit,
            defaultUnit: .bytes,
            defaultValue: "-")
        return .init(
            errorMessage: errorMessage,
            eosBalance: eosBalance,
            cpu: cpuLimit,
            net: netLimit,
            ram: ram,
            availableDurationUnits: availableDurationUnits,
            availableInformationStorageUnits: availableInformationsStorageUnits)
    }
    
    private func makeRam(
        response: Observable<GetAccountResponseDTO>,
        error: Observable<Error?>,
        unit: Observable<UnitInformationStorage>,
        defaultUnit: UnitInformationStorage,
        defaultValue: String
    ) -> Output.RamUsage {
        let quota = composeMeasurementValueOrError(
            value: response.map(\.ramQuota),
            error: error,
            defaultValue: defaultValue,
            unit: unit,
            defaultUnit: defaultUnit).startWith(defaultValue)
        
        let usage = composeMeasurementValueOrError(
            value: response.map(\.ramUsage),
            error: error,
            defaultValue: defaultValue,
            unit: unit,
            defaultUnit: defaultUnit).startWith(defaultValue)
        
        let unit = unit.map { measurementFormatter.string(from: $0) }.asDriver(onErrorJustReturn: "")
        return .init(quota: quota, usage: usage, unit: unit)
    }
    
    private func makeLimit<T: Dimension>(
        limit: Observable<GetAccountLimitDTO>,
        error: Observable<Error?>,
        unit: Observable<T>,
        defaultUnit: T,
        defaultValue: String
    ) -> Output.ResourceLimit {
        let max = composeMeasurementValueOrError(
            value: limit.map(\.max),
            error: error,
            defaultValue: defaultValue,
            unit: unit,
            defaultUnit: defaultUnit)
            .startWith(defaultValue)
        let available = composeMeasurementValueOrError(
            value: limit.map(\.available),
            error: error,
            defaultValue: defaultValue,
            unit: unit,
            defaultUnit: defaultUnit).startWith(defaultValue)
        let used = composeMeasurementValueOrError(
            value: limit.map(\.used),
            error: error,
            defaultValue: defaultValue,
            unit: unit,
            defaultUnit: defaultUnit).startWith(defaultValue)
        let unit = unit.map { measurementFormatter.string(from: $0) }.asDriver(onErrorJustReturn: "")
        return .init(max: max, available: available, used: used, unit: unit)
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
    
    private func formatError(error: Observable<Error?>) -> Driver<String?> {
        let emptyError = error.filter { $0 == nil }.map { _ -> String? in nil }
        let errorMessage = error.compactMap { $0 }.map { error -> String? in
            switch error {
            case let APIError.invalidStatusCode(code) where code == 500:
                return NSLocalizedString("error.accountNotFound", comment: "")
            default:
                if error.isNetworkError {
                    return NSLocalizedString("error.networkConnectionIsDown", comment: "")
                }
                return NSLocalizedString("error.generic", comment: "")
            }
        }
        return Observable.merge(emptyError, errorMessage).asDriver(onErrorJustReturn: nil)
    }
}

