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
    
    @IBOutlet weak var eosBalanceLabel: UILabel!
    @IBOutlet weak var cpuMaxValue: UILabel!
    @IBOutlet weak var cpuAvailableValue: UILabel!
    @IBOutlet weak var cpuUsedValue: UILabel!
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
        let input = SearchViewModel.Input(
            searchInput: searchInput,
            searchClick: searchClicked)
        let output = viewModel.transform(input: input)
        output.eosBalance.drive(eosBalanceLabel.rx.text).disposed(by: disposeBag)
        output.cpu.max.drive(cpuMaxValue.rx.text).disposed(by: disposeBag)
        output.cpu.available.drive(cpuAvailableValue.rx.text).disposed(by: disposeBag)
        output.cpu.used.drive(cpuUsedValue.rx.text).disposed(by: disposeBag)
        output.net.max.drive(netMaxValue.rx.text).disposed(by: disposeBag)
        output.net.available.drive(netAvailableValue.rx.text).disposed(by: disposeBag)
        output.net.used.drive(netUsedValue.rx.text).disposed(by: disposeBag)
        output.ram.quota.drive(ramQuotaValue.rx.text).disposed(by: disposeBag)
        output.ram.usage.drive(ramUsageValue.rx.text).disposed(by: disposeBag)
    }
}
