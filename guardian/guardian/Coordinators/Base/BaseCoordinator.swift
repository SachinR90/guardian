//
//  BaseCoordinator.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject, Presentable {
  var childCoordinators: [Coordinator] { get }
  func addChildCoordinator(_ coordinator: Coordinator)
  func removeChildCoordinator(_ coordinator: Coordinator?)
  func removeAllChildCoordinators()
  func start()
}

class BaseCoordinator<R: RouterType>: NSObject, Coordinator {
  var childCoordinators: [Coordinator] = []
  let router: R
  init(router: R) {
    self.router = router
  }
    
  // add only unique object
  func addChildCoordinator(_ coordinator: Coordinator) {
    guard !childCoordinators.contains(where: { $0 === coordinator }) else { return }
    childCoordinators.append(coordinator)
  }
    
  func removeChildCoordinator(_ coordinator: Coordinator?) {
    guard childCoordinators.isEmpty == false, let coordinator = coordinator else {
      return
    }
    coordinator.childCoordinators
      .filter { $0 !== coordinator }
      .forEach { coordinator.removeChildCoordinator($0) }
    for (index, element) in childCoordinators.enumerated() where element === coordinator {
      childCoordinators.remove(at: index)
    }
  }
    
  func removeAllChildCoordinators() {
    childCoordinators.forEach { removeChildCoordinator($0) }
  }
    
  func start() {}
    
  func toPresent() -> UIViewController {
    router.toPresent()
  }
  
  func presented(from presentable: Presentable?) {}
}
