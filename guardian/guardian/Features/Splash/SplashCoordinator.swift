//
//  SplashCoordinator.swift
//  guardian
//
//  Created by Sachin Rao on 18/12/21.
//

import Foundation
import RxSwift
import UIKit

class SplashCoordinator: NavigationControllerCoordinator {
  typealias Dependency = SplashViewModelInjectable & ViewControllerInjectable
  init(router: NavigationRouter, dependency: Dependency) {
    self.dependency = dependency
    super.init(router: router)
  }

  // MARK: Private Members

  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private var vcProvider: ViewControllerProvider {
    dependency.viewControllerProvider
  }

  var onSplashCompleteEvent: (() -> Void)?
  override func toPresent() -> UIViewController {
    makeSplasViewController()
  }

  private final func makeSplasViewController() -> UIViewController {
    let viewModel = dependency.splashViewModel
    viewModel.onSplashCompleted
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.onSplashCompleteEvent?()
      }).disposed(by: disposeBag)
    return SplashViewController(viewModel: viewModel)
  }
}
