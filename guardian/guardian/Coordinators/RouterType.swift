//
//  RouterType.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

protocol Dismissable {
  func onDismiss(animated: Bool, completion: (() -> Void)?)
}

protocol RouterType: Presentable {
  associatedtype RootViewController: UIViewController
  var rootViewController: RootViewController { get }
}

class Router<RootViewController: UIViewController>: NSObject, RouterType {
  private let _rootViewController: RootViewController
  var rootViewController: RootViewController {
    _rootViewController
  }

  public init(rootViewController: RootViewController) {
    self._rootViewController = rootViewController
  }

  public init<R: RouterType>(_ routerType: R) where R.RootViewController == RootViewController {
    self._rootViewController = routerType.rootViewController
  }

  func toPresent() -> UIViewController {
    rootViewController
  }

  func presented(from presentable: Presentable?) {}
}

extension RouterType {
  func present(
    _ preset: Presentable,
    animated: Bool, animation: Animation? = nil,
    modalPresentationStyle: UIModalPresentationStyle = .automatic,
    completion: (() -> Void)? = nil) {}

  func presentOnRoute() {}

  func embed() {}
  func dismiss() {}
  func dismissOnRoute() {}
  func dismissAll() {}
}

// This will be triggered on Pull down to dismiss on presented controller.
extension UIViewController: UIAdaptivePresentationControllerDelegate {
  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    if let presentedVC = presentationController.presentedViewController as? Dismissable {
      presentedVC.onDismiss(animated: true, completion: nil)
    }
  }
}
