//
//  SearchViewController.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import UIKit

class SearchViewController: UIViewController {

    // MARK: - Private properties -
    private let viewModel: SearchViewModel
    
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
        bindViewModel()
        // Do any additional setup after loading the view.
    }
}

private extension SearchViewController {
    func bindViewModel() {
        let input = SearchViewModel.Input()
        let output = viewModel.transform(input: input)
        // TODO: Add binding...
    }
}
