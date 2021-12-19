//
//  HomeCoordinator.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import RxSwift
import UIKit

class HomeCoordinator: NavigationControllerCoordinator {
  init(router: NavigationRouter, dependency: Dependency) {
    self.dependency = dependency
    super.init(router: router)
  }

  typealias Dependency = AllInjectables

  private let disposeBag = DisposeBag()
  private(set) var dependency: Dependency
  private var vcProvider: ViewControllerProvider {
    dependency.viewControllerProvider
  }

  override func toPresent() -> UIViewController {
    makeHomeViewController()
  }

  func makeHomeViewController() -> HomeViewController {
    let homeViewModel = dependency.homeViewModel
    homeViewModel.onShowDetailEvent.observe(on: MainScheduler.instance).subscribe { [weak self] news in
      guard let self = self, let news = news.element else { return }
      self.showDetails(for: news)
    }.disposed(by: disposeBag)
    return vcProvider.makeHomeViewController(with: homeViewModel)
  }
}

extension HomeCoordinator {
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
