//
//  HomeCoordinator.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit
protocol HomeCoordinatorDelegate: NSObject {
  func showDetails(for newItem: News)
}

class HomeCoordinator: NavigationControllerCoordinator {
  init(router: NavigationRouter, dependency: Dependency) {
    self.dependency = dependency
    super.init(router: router)
  }

  typealias Dependency = HomeViewModelInjectable & ViewControllerInjectable

  private(set) var dependency: Dependency
  private var vcProvider: ViewControllerProvider {
    dependency.viewControllerProvider
  }

  override func toPresent() -> UIViewController {
    makeHomeViewController()
  }

  func makeHomeViewController() -> HomeViewController {
    let homeViewModel = dependency.homeViewModel
    return vcProvider.makeHomeViewController(with: homeViewModel)
  }
}

extension HomeCoordinator: HomeCoordinatorDelegate {
  func showDetails(for newItem: News) {}
}
