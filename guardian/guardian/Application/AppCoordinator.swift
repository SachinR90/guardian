//
//  AppCoordinator.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

class AppCoordinator: NavigationControllerCoordinator {
  init(router: NavigationRouter, dependencies: AllInjectables) {
    self.dependency = dependencies
    super.init(router: router)
  }

  private var dependency: AllInjectables
  private var vcProvider: ViewControllerProvider {
    ViewControllerFactory(dependency: dependency)
  }

  private weak var homeCoordinator: HomeCoordinator?

  override func start() {
    startMainFlow()
  }

  func startMainFlow() {
    if homeCoordinator == nil {
      let coordinator = HomeCoordinator(router: router, dependency: dependency)
      addChildCoordinator(coordinator)
      homeCoordinator = coordinator
      coordinator.start()
      router.set([coordinator], hideBar: false, animated: false, animation: nil)
    }
  }
}
