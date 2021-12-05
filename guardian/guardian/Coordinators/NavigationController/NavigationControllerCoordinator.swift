//
//  NavigationControllerCoordinator.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation

class NavigationControllerCoordinator: BaseCoordinator<NavigationRouter> {
  func popToRoot(animated: Bool = false, animation: Animation? = .slideOver) {
    if !router.rootViewController.viewControllers.isEmpty {
      if animated {
        router.popToRoot(animated: true, animation: animation)
      } else {
        router.popToRoot()
      }
    }
    /// Although all the child view controllers should have been removed from above
    /// but in case anything left should be removed as well
    removeAllChildCoordinators()
  }
}
