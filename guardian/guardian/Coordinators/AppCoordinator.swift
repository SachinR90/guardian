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

  override func start() {
    launchSplashFlow()
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      self?.startMainFlow()
    }
  }

  func launchSplashFlow() {}

  func startMainFlow() {}
}
