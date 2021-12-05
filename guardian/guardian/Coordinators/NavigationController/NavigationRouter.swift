//
//  NavigationRouter.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

class NavigationRouter: Router<UINavigationController> {
  public let animationDelegate = NavigationDelegate()
  private var popCompletions: [UIViewController: () -> Void]

  public init(navigationController: UINavigationController) {
    popCompletions = [:]
    super.init(rootViewController: navigationController)

    // Set the navigation controller's delegate to self if not set already
    if rootViewController.delegate == nil {
      rootViewController.delegate = animationDelegate
    }

    // Closure that is called when any coordinator is popped from the navigation.
    // PoppedViewController is the first view controller in the poppedCoordinator.
    // In this closure we call the parent coordinator's poppedCompletion.
    animationDelegate.popCompletion = { [weak self] poppedViewController in
      self?.runCompletion(for: poppedViewController)
    }
  }

  ///
  /// This represents a fallback-delegate to be notified about navigation controller events.
  /// It is further used to call animation methods when no animation has been specified in the transition.
  ///
  public var delegate: UINavigationControllerDelegate? {
    get {
      animationDelegate.delegate
    }
    set {
      animationDelegate.delegate = newValue
    }
  }

  override public func toPresent() -> UIViewController {
    rootViewController
  }

  public func push(
    _ presentable: Presentable,
    hideBottomBar: Bool = false,
    animated: Bool = true,
    animation: Animation? = nil,
    pushCompletion: (() -> Void)? = nil,
    popCompletion: (() -> Void)? = nil
  ) {
    // Avoid pushing UINavigationController onto stack
    let controllerToPush = presentable.toPresent()
    guard controllerToPush is UINavigationController == false
    else {
      assertionFailure("UINavigationController can not be pushed onto an already existing UINavigationController.")
      return
    }

    // Store the popCompletion so that it can be called when this controller is popped
    if let popCompletion = popCompletion {
      popCompletions[controllerToPush] = popCompletion
    }

    controllerToPush.hidesBottomBarWhenPushed = hideBottomBar
    rootViewController.push(controllerToPush, animated: animated,
                            animation: animation, completion: pushCompletion)
  }

  public func pop(
    animated: Bool = false,
    animation: Animation? = nil,
    completion: ((UIViewController?) -> Void)? = nil
  ) {
    rootViewController.pop(animated: animated, animation: animation) { poppedViewController in
      completion?(poppedViewController)
      guard let poppedVC = poppedViewController else { return }
      self.runCompletion(for: poppedVC)
    }
  }

  public func popTo(
    _ presentable: Presentable,
    animated: Bool = false,
    animation: Animation? = nil,
    completion: (([UIViewController]?) -> Void)? = nil
  ) {
    rootViewController.popToViewController(presentable.toPresent(),
                                           animated: animated,
                                           animation: animation) {
      poppedViewControllers in
      completion?(poppedViewControllers)
      guard let poppedVCs = poppedViewControllers else { return }
      poppedVCs.forEach { self.runCompletion(for: $0) }
    }
  }

  public func popToRoot(
    animated: Bool = false,
    animation: Animation? = nil,
    completion: (([UIViewController]?) -> Void)? = nil
  ) {
    rootViewController.popToViewController(nil, animated: animated, animation: animation) {
      poppedViewControllers in
      completion?(poppedViewControllers)
      guard let poppedVCs = poppedViewControllers else { return }
      poppedVCs.forEach { self.runCompletion(for: $0) }
    }
  }

  public func set(
    _ presentables: [Presentable],
    hideBar: Bool = false,
    animated: Bool = false,
    animation: Animation? = nil,
    completion: (() -> Void)? = nil
  ) {
    // Call all completions so all coordinators can be deallocated
    popCompletions.forEach { $0.value() }
    popCompletions.removeAll()

    rootViewController.isNavigationBarHidden = hideBar
    rootViewController.set(presentables.map { $0.toPresent() },
                           animated: animated, animation: animation,
                           completion: completion)
  }

  fileprivate func runCompletion(for controller: UIViewController) {
    guard let completion = popCompletions[controller] else { return }
    completion()
    popCompletions.removeValue(forKey: controller)
  }
}
