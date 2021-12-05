//
//  Container.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

public protocol Container {
  ///
  /// The view of the Container.
  ///
  /// - Note:
  ///     It might not exist for a `UIViewController`.
  ///
  var view: UIView! { get }

  ///
  /// The viewController of the Container.
  ///
  /// - Note:
  ///     It might not exist for a `UIView`.
  ///
  var viewController: UIViewController! { get }
}

// MARK: - Extensions

extension UIViewController: Container {
  public var viewController: UIViewController! { self }
}

extension UIView: Container {
  public var viewController: UIViewController! {
    viewController(for: self)
  }

  public var view: UIView! { self }
}

extension UIView {
  private func viewController(for responder: UIResponder) -> UIViewController? {
    if let viewController = responder as? UIViewController {
      return viewController
    }

    if let nextResponser = responder.next {
      return viewController(for: nextResponser)
    }

    return nil
  }
}
