//
//  NewsDetailsViewModel.swift
//  guardian
//
//  Created by Sachin Rao on 06/12/21.
//

import Foundation
import UIKit

protocol NewsDetailsViewModelType {
  // for coordinator
  var urlClicked: ((URL) -> Void)? { get set }
  // for viewciontroller
  func navigateToUrl()

  var newsItem: News? { get set }
}

protocol NewsDetailsViewModelDelegate: AnyObject {}

class NewsDetailsViewModel: NewsDetailsViewModelType {
  func navigateToUrl() {
    // extract data and perform url Clikced
    if let url = newsItem?.webUrl, let uri = URL(string: url) {
//      self.urlClicked?(uri)
      UIApplication.shared.open(uri)
    }
  }

  var urlClicked: ((URL) -> Void)?

  func navigateToViewController() {}

  var newsItem: News?
}
