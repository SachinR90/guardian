//
//  UIViewControllerStatePresentable.swift
//  guardian
//
//  Created by Sachin Rao on 15/12/21.
//

import Foundation
import UIKit

/*
 This will be composed inside regulat View state of a screen.
 Then all the work will be delegated to UIListStatePresentable's render() whenever state changes
 */
enum UIViewControllerState: Equatable {
  case data
  case loading
  case error(message: String)
  case empty(message: String)
}

/**
 Configs for setting up child state view controllers
 */
struct UIViewControllerStateInsetConfig {
  /**
   EdgeInsets for loading state view controller to be applied while adding it
   */
  let loadingStateInset: UIEdgeInsets?
  /**
   EdgeInsets for empty state view controller to be applied while adding it
   */
  let emptyStateInset: UIEdgeInsets?
  /**
   EdgeInsets for error state view controller to be applied while adding it
   */
  let errorStateInset: UIEdgeInsets?
}

/**
 A State presentable with defult handlings of data, loading, empty and error states for UIViewControllers
 */
protocol UIViewControllerStatePresentable: UIViewController {
  /**
   LoadingStateViewController that will be used to show loaders.
   Defult handling will create one if not provided
   */
  var loadingStateViewController: LoadingStateViewController? { get set }

  /**
   EmptyStateViewController that will be used to show empty/error states
   Default handling will create one if not provided
   */
  var emptyStateViewController: EmptyStateViewController? { get set }

  /**
   ErrorStateViewController that will be used to show empty/error states
   Default handling will create one if not provided
   */
  var errorStateViewController: ErrorStateViewController? { get set }

  /**
   Data views that re present when loading is done and there is no error/empty state
   UIListStatePresentable will hide/unhide these at appropriate time according to state
   */
  var dataViews: [UIView] { get }

  /**
   EdgeInsets for loading, empty and error state controllers.
   Default implementation adds child controllers over parent view of  conforming view controller.
   */
  var insetConfig: UIViewControllerStateInsetConfig? { get }

  /**
   This is the title of the button on the error state view controller
   Retry by default.
   */
  var errorStateButtonTitle: String { get }
}

/**
 Default values for UIViewControllerStatePresentable
 */
extension UIViewControllerStatePresentable {
  var dataViews: [UIView] {
    []
  }

  var insetConfig: UIViewControllerStateInsetConfig? {
    nil
  }

  var errorStateButtonTitle: String {
   "Retry"
  }
}

extension UIViewControllerStatePresentable where Self: UIViewController {
  // MARK: - Loading View

  /**
   Render UI from state. All the state specific blocks will be called for controller specific handling. If Controller doesn't have specific handling, these blocks can simply be nil as data views will automatically be handled.
   */
  func render(
    from state: UIViewControllerState,
    retryBlock: (() -> Void)?,
    onLoading: (() -> Void)? = nil,
    onData: (() -> Void)? = nil,
    onEmpty: (() -> Void)? = nil,
    onError: (() -> Void)? = nil
  ) {
    switch state {
      case .loading:
        setupLoadingState()
        onLoading?()
      case .data:
        setupCompletedState()
        DispatchQueue.main.async{onData?()}
      case let .empty(message):
        setupEmptyState(message)
        onEmpty?()
      case let .error(message):
        setupErrorState(message, retryAction: retryBlock)
        onError?()
    }
  }

  private func hideShowDataViews(hide: Bool) {
    dataViews.forEach {
      $0.isHidden = hide
    }
  }

  private func setupLoadingState() {
    emptyStateViewController?.remove()

    hideShowDataViews(hide: true)

    if loadingStateViewController == nil {
      loadingStateViewController = LoadingStateViewController()
    }
    guard let loadingViewController = loadingStateViewController else { return }

    add(containerViewController: loadingViewController, layoutMargins: insetConfig?.loadingStateInset)
  }

  private func setupCompletedState() {
    hideShowDataViews(hide: false)
    removeNonDataViewControllers()
  }

  private func removeNonDataViewControllers() {
    loadingStateViewController?.remove()
    emptyStateViewController?.remove()
    errorStateViewController?.remove()
  }

  // MARK: - Empty View

  private func setupEmptyState(
    _ message: String
  ) {
    hideShowDataViews(hide: true)

    removeNonDataViewControllers()

    if emptyStateViewController == nil {
      emptyStateViewController = EmptyStateViewController(with: message)
    }
    guard let emptyDataViewController = emptyStateViewController else { return }
    add(containerViewController: emptyDataViewController, layoutMargins: insetConfig?.emptyStateInset)
  }

  // MARK: - Error View

  private func setupErrorState(
    _ message: String,
    retryAction: (() -> Void)?
  ) {
    hideShowDataViews(hide: true)
    removeNonDataViewControllers()

    let retryBlock = { [weak self] in
      self?.emptyStateViewController?.remove()
      self?.errorStateViewController?.remove()
      retryAction?()
    }

    if errorStateViewController == nil {
      errorStateViewController = ErrorStateViewController(with: message,
                                                          retryAction: retryBlock,
                                                          buttonTitle: errorStateButtonTitle)
    }

    guard let errorDataViewController = errorStateViewController else { return }
    add(containerViewController: errorDataViewController, layoutMargins: insetConfig?.errorStateInset)
  }
}
