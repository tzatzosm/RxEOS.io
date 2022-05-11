//
//  SearchViewModelTests.swift
//  Rxeos.ioTests
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import Rxeos_io

class SearchViewModelTests: XCTestCase {
    
    private var scheduler: TestScheduler!
    private let disposeBag = DisposeBag()
    
    private var service: MockAPIService!
    private var validator: MockValidator!
    private var sut: SearchViewModel!
    private var input: SearchViewModel.Input!
    private var output: SearchViewModel.Output!
    
    private let responseDTO = GetAccountResponseDTO(
        accountName: "marsel_tzatzo",
        coreLiquidBalance: "10 EOS",
        cpuLimit: .init(used: 10000, available: 10000, max: 10000),
        netLimit: .init(used: 10000, available: 10000, max: 10000),
        ramQuota: 20000, ramUsage: 10000)
    
    private let measurementFormatter: MeasurementFormatter = {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        return measurementFormatter
    }()
    
    private let accountNameSubject = BehaviorSubject<String>(value: "accountName")
    private let searchSubject = PublishSubject<()>()
    private let cpuDurationUnitSubject = PublishSubject<UnitDuration>()
    private let ramStorageUnitSubject = PublishSubject<UnitInformationStorage>()
    private let netStorageUnitSubject = PublishSubject<UnitInformationStorage>()
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        service = MockAPIService()
        validator = MockValidator()
        sut = SearchViewModel(apiService: service, inputValidator: validator)
        input = .init(
            searchInput: accountNameSubject.asObservable(),
            searchClick: searchSubject.asObservable(),
            ramStorageUnit: ramStorageUnitSubject.asObservable().startWith(.bytes),
            cpuDurationUnit: cpuDurationUnitSubject.asObservable().startWith(.microseconds),
            netStorageUnit: netStorageUnitSubject.asObservable().startWith(.bytes))
        output = sut.transform(input: input)
    }
    
    func test_whenViewModelIsTransformed_errorMessageIsNil() {
        // When
        let errorMessage = scheduler.createObserver(String?.self)
        output.errorMessage.drive(errorMessage).disposed(by: disposeBag)
        
        // Then
        XCTAssertEqual(errorMessage.events, [.next(0, nil)])
    }
    
    func test_whenInputIsInvalid_errorMessageIsNotNilAndItsValueIsNetworkConnectionDown() {
        // Given
        validator.isValid = false
        
        // When
        let errorMessage = scheduler.createObserver(String?.self)
        output.errorMessage.drive(errorMessage).disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(9, "searchTerm")])
            .bind(to: accountNameSubject)
            .disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: searchSubject)
            .disposed(by: disposeBag)
        scheduler.start()
        
        // Then
        XCTAssertEqual(
            errorMessage.events,
            [.next(0, nil), .next(10, NSLocalizedString("error.validationFailed", comment: ""))])
    }
    
    func test_whenErrorIsNoNetwork_errorMessageIsNotNilAndItsValueIsNetworkConnectionDown() {
        // Given
        service.error = NSError(domain: "", code: -1020)
        
        // When
        let errorMessage = scheduler.createObserver(String?.self)
        output.errorMessage.drive(errorMessage).disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(9, "searchTerm")])
            .bind(to: accountNameSubject)
            .disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: searchSubject)
            .disposed(by: disposeBag)
        scheduler.start()
        
        // Then
        XCTAssertEqual(
            errorMessage.events,
            [.next(0, nil), .next(10, NSLocalizedString("error.networkConnectionIsDown", comment: ""))])
    }
    
    func test_whenError500_errorMessageIsNotNilAndItsValueIsAccountNotFound() {
        // Given
        service.error = APIError.invalidStatusCode(code: 500)
        
        // When
        let errorMessage = scheduler.createObserver(String?.self)
        output.errorMessage.drive(errorMessage).disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(9, "searchTerm")])
            .bind(to: accountNameSubject)
            .disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: searchSubject)
            .disposed(by: disposeBag)
        scheduler.start()
        
        // Then
        XCTAssertEqual(
            errorMessage.events,
            [.next(0, nil), .next(10, NSLocalizedString("error.accountNotFound", comment: ""))])
    }
    
    func test_whenErrorIsUnidentified_errorMessageIsNotNilAndItsValueIsGenericError() {
        // Given
        service.error = APIError.invalidStatusCode(code: 444)
        
        // When
        let errorMessage = scheduler.createObserver(String?.self)
        output.errorMessage.drive(errorMessage).disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(9, "searchTerm")])
            .bind(to: accountNameSubject)
            .disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: searchSubject)
            .disposed(by: disposeBag)
        scheduler.start()
        
        // Then
        XCTAssertEqual(
            errorMessage.events,
            [.next(0, nil), .next(10, NSLocalizedString("error.generic", comment: ""))])
    }
    
    func test_whenError_allValuesAreSetToDefault() {
        // Given
        service.error = APIError.invalidStatusCode(code: 444)
        
        // When
        let eosBalance = scheduler.createObserver(String.self)
        output.eosBalance.drive(eosBalance).disposed(by: disposeBag)
        let ramUsage = scheduler.createObserver(String.self)
        output.ram.usage.drive(ramUsage).disposed(by: disposeBag)
        let ramQuota = scheduler.createObserver(String.self)
        output.ram.quota.drive(ramQuota).disposed(by: disposeBag)
        let netMax = scheduler.createObserver(String.self)
        output.net.max.drive(netMax).disposed(by: disposeBag)
        let netAvailable = scheduler.createObserver(String.self)
        output.net.available.drive(netAvailable).disposed(by: disposeBag)
        let netUsed = scheduler.createObserver(String.self)
        output.net.used.drive(netUsed).disposed(by: disposeBag)
        let cpuMax = scheduler.createObserver(String.self)
        output.cpu.max.drive(cpuMax).disposed(by: disposeBag)
        let cpuAvailable = scheduler.createObserver(String.self)
        output.cpu.available.drive(cpuAvailable).disposed(by: disposeBag)
        let cpuUsed = scheduler.createObserver(String.self)
        output.cpu.used.drive(cpuUsed).disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(9, "searchTerm")])
            .bind(to: accountNameSubject)
            .disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: searchSubject)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        // Then
        [eosBalance, ramUsage, ramQuota, netMax, netAvailable, netUsed, cpuMax, cpuAvailable, cpuUsed]
            .forEach {
                XCTAssertEqual($0.events, [.next(0, "-"), .next(10, "-")])
            }
    }
    
    func test_whenLoadingCompletesSuccessfully_eosBalanceIsCorrent() {
        // Given
        service.response = responseDTO
        
        // When
        let eosBalance = scheduler.createObserver(String.self)
        output.eosBalance.drive(eosBalance).disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(9, "searchTerm")])
            .bind(to: accountNameSubject)
            .disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: searchSubject)
            .disposed(by: disposeBag)
        scheduler.start()
        
        // Then
        XCTAssertEqual(
            eosBalance.events,
            [.next(0, "-"), .next(10, responseDTO.coreLiquidBalance)])
    }
    
    func test_whenLoadingCompletesSuccessfully_ramValuesAreCorrect() {
        // Given
        service.response = responseDTO
        
        // When
        let ramUsage = scheduler.createObserver(String.self)
        output.ram.usage.drive(ramUsage).disposed(by: disposeBag)
        let ramQuota = scheduler.createObserver(String.self)
        output.ram.quota.drive(ramQuota).disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(9, "searchTerm")])
            .bind(to: accountNameSubject)
            .disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: searchSubject)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        // Then
        let ramQuotaMeasurement = Measurement(
            value: Double(responseDTO.ramQuota),
            unit: UnitInformationStorage.bytes)
        XCTAssertEqual(
            ramQuota.events,
            [.next(0, "-"), .next(10, measurementFormatter.string(from: ramQuotaMeasurement))])
        let ramUsageMeasurement = Measurement(
            value: Double(responseDTO.ramUsage),
            unit: UnitInformationStorage.bytes)
        XCTAssertEqual(
            ramUsage.events,
            [.next(0, "-"), .next(10, measurementFormatter.string(from: ramUsageMeasurement))])
    }
    
    func test_whenLoadingCompletesSuccessfully_cpuValuesAreCorrect() {
        // Given
        service.response = responseDTO
        
        // When
        let cpuMax = scheduler.createObserver(String.self)
        output.cpu.max.drive(cpuMax).disposed(by: disposeBag)
        let cpuAvailable = scheduler.createObserver(String.self)
        output.cpu.available.drive(cpuAvailable).disposed(by: disposeBag)
        let cpuUsed = scheduler.createObserver(String.self)
        output.cpu.used.drive(cpuUsed).disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(9, "searchTerm")])
            .bind(to: accountNameSubject)
            .disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: searchSubject)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        // Then
        let cpuMaxMeasurement = Measurement(
            value: Double(responseDTO.cpuLimit.max),
            unit: UnitDuration.microseconds)
        XCTAssertEqual(
            cpuMax.events,
            [.next(0, "-"), .next(10, measurementFormatter.string(from: cpuMaxMeasurement))])
        let cpuAvailableMeasurement = Measurement(
            value: Double(responseDTO.cpuLimit.available),
            unit: UnitDuration.microseconds)
        XCTAssertEqual(
            cpuAvailable.events,
            [.next(0, "-"), .next(10, measurementFormatter.string(from: cpuAvailableMeasurement))])
        let cpuUsedMeasurement = Measurement(
            value: Double(responseDTO.cpuLimit.used),
            unit: UnitDuration.microseconds)
        XCTAssertEqual(
            cpuUsed.events,
            [.next(0, "-"), .next(10, measurementFormatter.string(from: cpuUsedMeasurement))])
    }
    
    func test_whenLoadingCompletesSuccessfully_netValuesAreCorrect() {
        // Given
        service.response = responseDTO
        
        // When
        let netMax = scheduler.createObserver(String.self)
        output.net.max.drive(netMax).disposed(by: disposeBag)
        let netAvailable = scheduler.createObserver(String.self)
        output.net.available.drive(netAvailable).disposed(by: disposeBag)
        let netUsed = scheduler.createObserver(String.self)
        output.net.used.drive(netUsed).disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(9, "searchTerm")])
            .bind(to: accountNameSubject)
            .disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: searchSubject)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        // Then
        let netMaxMeasurement = Measurement(
            value: Double(responseDTO.netLimit.max),
            unit: UnitInformationStorage.bytes)
        XCTAssertEqual(
            netMax.events,
            [.next(0, "-"), .next(10, measurementFormatter.string(from: netMaxMeasurement))])
        let netAvailableMeasurement = Measurement(
            value: Double(responseDTO.netLimit.available),
            unit: UnitInformationStorage.bytes)
        XCTAssertEqual(
            netAvailable.events,
            [.next(0, "-"), .next(10, measurementFormatter.string(from: netAvailableMeasurement))])
        let netUsedMeasurement = Measurement(
            value: Double(responseDTO.netLimit.used),
            unit: UnitInformationStorage.bytes)
        XCTAssertEqual(
            netUsed.events,
            [.next(0, "-"), .next(10, measurementFormatter.string(from: netUsedMeasurement))])
    }
    
    
    
}
