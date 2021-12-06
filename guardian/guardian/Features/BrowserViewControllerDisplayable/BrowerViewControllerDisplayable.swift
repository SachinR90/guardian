//
//  BrowerViewControllerDisplayable.swift
//  guardian
//
//  Created by Sachin Rao on 06/12/21.
//

import Foundation
import ProgressWebViewController
import UIKit

protocol BrowserViewControllerDisplayable {
  func pushBrowserViewController(
    withRequest request: URLRequest,
    title: String?,
    showToolbarOptions: Bool
  )
}

/// Push the BrowserViewController into a NavigationRouter
extension BrowserViewControllerDisplayable {
  func pushBrowserViewController<R: NavigationRouter>(
    withRequest request: URLRequest,
    title: String?,
    showToolbarOptions: Bool
  ) where Self: BaseCoordinator<R> {
    let progressWebViewController = makeProgressWebViewController(withRequest: request,
                                                                  title: title,
                                                                  showToolbarOptions: showToolbarOptions)
    // router.push(progressWebViewController)
    self.router.push(progressWebViewController, animated: true, animation: .none)
  }
}

private extension BrowserViewControllerDisplayable {
  func makeProgressWebViewController(
    withRequest request: URLRequest,
    title: String?,
    showToolbarOptions: Bool,
    errorMessage: String? = nil
  ) -> ProgressWebViewController {
    let progressWebViewController = ProgressWebViewController()
    progressWebViewController.url = request.url
    progressWebViewController.defaultHeaders = request.allHTTPHeaderFields
    progressWebViewController.navigationItem.title = title
    progressWebViewController.websiteTitleInNavigationBar = (title == nil)
    progressWebViewController.toolbarItemTypes = showToolbarOptions ? [.back, .forward, .reload] : []
    return progressWebViewController
  }
}
