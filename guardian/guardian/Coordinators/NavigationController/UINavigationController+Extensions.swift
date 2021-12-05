//
//  UINavigationController+Extensions.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

extension UINavigationController {
  func push(
    _ viewController: UIViewController,
    animated: Bool,
    animation: Animation?,
    completion: (() -> Void)? = nil
  ) {
    if let animation = animation {
      viewController.transitioningDelegate = animation
    }
    assert(animation == nil || animationDelegate != nil, """
    Animation is specified but the navigation controller has no delegate to handle it.
    """)

    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)

    autoreleasepool {
      pushViewController(viewController, animated: animated)
    }

    CATransaction.commit()
  }

  func pop(
    animated: Bool,
    animation: Animation?,
    completion: ((UIViewController?) -> Void)? = nil
  ) {
    if let animation = animation {
      topViewController?.transitioningDelegate = animation
    }
    assert(animation == nil || animationDelegate != nil, """
    Animation is specified but the navigation controller has no delegate to handle it.
    """)

    var poppedViewController: UIViewController?
    var popCompletion: (() -> Void)?
    if let completion = completion {
      popCompletion = {
        completion(poppedViewController)
      }
    }

    CATransaction.begin()
    CATransaction.setCompletionBlock(popCompletion)

    poppedViewController = autoreleasepool {
      popViewController(animated: animated)
    }

    CATransaction.commit()
  }

  func popToViewController(
    _ viewController: UIViewController?,
    animated: Bool,
    animation: Animation?,
    completion: (([UIViewController]?) -> Void)? = nil
  ) {
    if let animation = animation {
      topViewController?.transitioningDelegate = animation
      viewController?.transitioningDelegate = animation
    }

    assert(animation == nil || animationDelegate != nil, """
    Animation is specified but the navigation controller has no delegate to handle it.
    """)

    var poppedViewControllers: [UIViewController]?
    var popCompletion: (() -> Void)?
    if let completion = completion {
      popCompletion = {
        completion(poppedViewControllers)
      }
    }

    CATransaction.begin()
    CATransaction.setCompletionBlock(popCompletion)

    poppedViewControllers = autoreleasepool {
      var poppedControllers: [UIViewController]?
      if let viewController = viewController {
        poppedControllers = popToViewController(viewController, animated: animated)
      } else {
        poppedControllers = popToRootViewController(animated: animated)
      }

      return poppedControllers
    }

    CATransaction.commit()
  }

  func set(
    _ viewControllers: [UIViewController],
    animated: Bool,
    animation: Animation?,
    completion: (() -> Void)? = nil
  ) {
    if let animation = animation {
      viewControllers.last?.transitioningDelegate = animation
    }
    assert(animation == nil || animationDelegate != nil, """
    Animation is specified but the navigation controller has no delegate to handle it.
    """)

    CATransaction.begin()
    CATransaction.setCompletionBlock {
      if let animation = animation {
        viewControllers.forEach { $0.transitioningDelegate = animation }
      }
      completion?()
    }

    autoreleasepool {
      setViewControllers(viewControllers, animated: animated)
    }

    CATransaction.commit()
  }
}
