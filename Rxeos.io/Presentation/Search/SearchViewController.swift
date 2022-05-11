//
//  SearchViewController.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var eosBalanceLabel: UILabel!
    @IBOutlet weak var cpuMaxValue: UILabel!
    @IBOutlet weak var cpuAvailableValue: UILabel!
    @IBOutlet weak var cpuUsedValue: UILabel!
    @IBOutlet weak var cpuDurationUnitSelectionButton: UIButton!
    @IBOutlet weak var netMaxValue: UILabel!
    @IBOutlet weak var netAvailableValue: UILabel!
    @IBOutlet weak var netUsedValue: UILabel!
    @IBOutlet weak var ramQuotaValue: UILabel!
    @IBOutlet weak var ramUsageValue: UILabel!
    
    // MARK: - Private properties -
    private let viewModel: SearchViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle -
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        
        bindViewModel()
    }
}

private extension SearchViewController {
    func bindViewModel() {
        let searchInput = searchBar.rx.text.orEmpty.asObservable()
        let searchClicked = searchBar.rx.searchButtonClicked.asObservable()
        let cpuDurationUnitPublisher = PublishSubject<UnitDuration>()
        let input = SearchViewModel.Input(
            searchInput: searchInput,
            searchClick: searchClicked,
            cpuDurationUnit: cpuDurationUnitPublisher.startWith(.microseconds))
        let output = viewModel.transform(input: input)
        output.errorMessage.drive(errorLabel.rx.text).disposed(by: disposeBag)
        output.eosBalance.drive(eosBalanceLabel.rx.text).disposed(by: disposeBag)
        output.cpu.max.drive(cpuMaxValue.rx.text).disposed(by: disposeBag)
        output.cpu.available.drive(cpuAvailableValue.rx.text).disposed(by: disposeBag)
        output.cpu.used.drive(cpuUsedValue.rx.text).disposed(by: disposeBag)
        output.cpuDurationUnit.drive(cpuDurationUnitSelectionButton.rx.title(for: .normal)).disposed(by: disposeBag)
        output.net.max.drive(netMaxValue.rx.text).disposed(by: disposeBag)
        output.net.available.drive(netAvailableValue.rx.text).disposed(by: disposeBag)
        output.net.used.drive(netUsedValue.rx.text).disposed(by: disposeBag)
        output.ram.quota.drive(ramQuotaValue.rx.text).disposed(by: disposeBag)
        output.ram.usage.drive(ramUsageValue.rx.text).disposed(by: disposeBag)
        
        scrollView.rx.didScroll
            .bind(to: rx.dismissKeyboardBinder)
            .disposed(by: disposeBag)
        
        cpuDurationUnitSelectionButton.rx.tap
            .withLatestFrom(output.availableDurationUnits)
            .bind(to: rx.unitSelectionBinder(publisher: cpuDurationUnitPublisher))
            .disposed(by: disposeBag)
    }
    
    func showActionSheet<T: Dimension>(units: [T], publisher: PublishSubject<T>) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        units.forEach { unit in
            let action = UIAlertAction(title: unit.symbol, style: .default) { _ in
                publisher.onNext(unit)
            }
            actionSheet.addAction(action)
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
}


private extension Reactive where Base: SearchViewController {
    func unitSelectionBinder<T: Dimension>(publisher: PublishSubject<T>) -> Binder<[T]> {
        return Binder(base, binding: { base, units in
            base.showActionSheet(
                units: units, publisher: publisher)
        })
    }
    
    var dismissKeyboardBinder: Binder<()> {
        return Binder(base, binding: { base, _ in
            base.searchBar.endEditing(true)
        })
    }
}
