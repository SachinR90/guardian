//
//  NewsDetailsCoordinator.swift
//  guardian
//
//  Created by Sachin Rao on 06/12/21.
//

import Foundation
import UIKit

class NewsDetailsCoordinator: NavigationControllerCoordinator, BrowserViewControllerDisplayable {
  typealias Dependency =
    ViewControllerInjectable
      & NewsDetailsViewModelInjectable

  private var dependency: Dependency
  private var newsItem: News
  init(router: NavigationRouter, dependency: Dependency, newsItem: News) {
    self.dependency = dependency
    self.newsItem = newsItem
    super.init(router: router)
  }

  override func toPresent() -> UIViewController {
    makeNewsDetailsViewController()
  }

  func makeNewsDetailsViewController() -> NewsDetailsViewController {
    var newsDetailsViewModel = dependency.newsDetailsViewModel
    newsDetailsViewModel.newsItem = newsItem
    newsDetailsViewModel.urlClicked = { [weak self] url in
      self?.onUrlClicked(url: url)
    }
    return dependency.viewControllerProvider.makeNewsDetailsViewController(with: newsDetailsViewModel)
  }
}

extension NewsDetailsCoordinator {
  private func onUrlClicked(url: URL) {
    let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    pushBrowserViewController(withRequest: urlRequest,
                              title: "News Details",
                              showToolbarOptions: false)
  }
}
