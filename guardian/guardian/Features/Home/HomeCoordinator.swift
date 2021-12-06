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

  typealias Dependency = AllInjectables

  private(set) var dependency: Dependency
  private var vcProvider: ViewControllerProvider {
    dependency.viewControllerProvider
  }

  override func toPresent() -> UIViewController {
    makeHomeViewController()
  }

  func makeHomeViewController() -> HomeViewController {
    var homeViewModel = dependency.homeViewModel
    homeViewModel.coordinatorDelegate = self
    return vcProvider.makeHomeViewController(with: homeViewModel)
  }
}

extension HomeCoordinator: HomeCoordinatorDelegate {
  func showDetails(for newItem: News) {
    let detailCoordinator = NewsDetailsCoordinator(router: router, dependency: dependency, newsItem: newItem)
    addChildCoordinator(detailCoordinator)
    router.push(detailCoordinator,
                hideBottomBar: true,
                animation: .none,
                popCompletion: { [weak self, weak detailCoordinator] in self?.removeChildCoordinator(detailCoordinator)
                })
  }
}
