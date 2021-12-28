//
//  AppCoordinator.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import FirebaseRemoteConfig
import Foundation
import UIKit

class AppCoordinator: NavigationControllerCoordinator {
  init(router: NavigationRouter, dependencies: AllInjectables) {
    self.dependency = dependencies
    self.secureDataStore = dependency.securedDataStore
    super.init(router: router)
  }

  private let dependency: AllInjectables
  private let secureDataStore: SecuredDataStore

  private var vcProvider: ViewControllerProvider {
    ViewControllerFactory(dependency: dependency)
  }

  private weak var homeCoordinator: HomeCoordinator?
  private weak var splashCoordinator: SplashCoordinator?

  override func start() {
    if secureDataStore.hasGuardianKey() {
      startMainFlow()
    } else {
      startSplashFlow()
    }
  }

  func startMainFlow() {
    if homeCoordinator == nil {
      let coordinator = HomeCoordinator(router: router, dependency: dependency)
      addChildCoordinator(coordinator)
      homeCoordinator = coordinator
      coordinator.start()
      router.set([coordinator], hideBar: false, animated: true, animation: .fade)
    }
  }

  func startSplashFlow() {
    if splashCoordinator == nil {
      let coordinator = SplashCoordinator(router: router, dependency: dependency)
      addChildCoordinator(coordinator)
      splashCoordinator = coordinator
      splashCoordinator!.onSplashCompleteEvent = { [weak self] in
        guard let self = self else { return }
        self.removeChildCoordinator(self.splashCoordinator)
        self.start()
        self.splashCoordinator = nil
      }
      coordinator.start()
      router.set([coordinator], hideBar: true, animated: false, animation: nil)
    }
  }
}
