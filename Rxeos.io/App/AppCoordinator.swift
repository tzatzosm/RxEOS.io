//
//  AppCoordinator.swift
//  Rxeos.io
//
//  Created by Marsel Tzatzo on 11/5/22.
//

import Foundation
import UIKit

class AppCoordinator {
    private let window: UIWindow
    private let navigationController = UINavigationController()
    
    init(windowScene: UIWindowScene) {
        window = UIWindow(windowScene: windowScene)
    }
    
    func start() {
        let searchViewController = makeSearchViewController()
        navigationController.setViewControllers([searchViewController], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

private extension AppCoordinator {
    func makeSearchViewController() -> SearchViewController {
        return SearchViewController(viewModel: makeSearchViewModel())
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        return SearchViewModel(apiService: makeAPIService())
    }
    
    func makeAPIService() -> AnyAPIService {
        return DefaultAPIService(baseUrl: "https://eos.greymass.com", decoder: JSONDecoder.camelCaseDecoder)
    }
    
    func makeBaseURL() -> String {
        return "https://eos.greymass.com"
    }
}
