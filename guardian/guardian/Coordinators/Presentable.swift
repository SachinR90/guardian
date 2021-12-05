//
//  Presentable.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

///
/// Presentable represents all objects that can be presented (i.e. shown) to the user.
///
/// Therefore, it is useful for view controllers, coordinators and views.
/// Presentable is often used for transitions to allow for view controllers and coordinators to be transitioned to.
///
protocol Presentable {
  func toPresent() -> UIViewController

  ///
  /// This method is called whenever a Presentable is shown to the user.
  /// It further provides information about the context a presentable is shown in.
  ///
  /// - Parameter presentable:
  ///     The context in which the presentable is shown.
  ///     This could be a window, another viewController, a coordinator, etc.
  ///     `nil` is specified whenever a context cannot be easily determined.
  ///
  func presented(from presentable: Presentable?)
}

extension UIViewController: Presentable {
  public func toPresent() -> UIViewController {
    self
  }

  func presented(from presentable: Presentable?) {}
}
