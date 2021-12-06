//
//  ViewControllerFactory.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

protocol ViewControllerProvider {
  func makeHomeViewController(with vm: HomeViewModelType) -> HomeViewController
  func makeNewsDetailsViewController(with vm: NewsDetailsViewModelType) -> NewsDetailsViewController
}

struct ViewControllerFactory: ViewControllerProvider {
  typealias Dependency = AllInjectables
  private let dependency: Dependency
  init(dependency: Dependency) {
    self.dependency = dependency
  }

  func makeHomeViewController(with vm: HomeViewModelType) -> HomeViewController {
    HomeViewController(viewModel: vm)
  }

  func makeNewsDetailsViewController(with vm: NewsDetailsViewModelType) -> NewsDetailsViewController {
    NewsDetailsViewController(viewModel: vm)
  }
}
