//
//  ViewControllerFactory.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

protocol ViewControllerProvider {}

struct ViewControllerFactory: ViewControllerProvider {
  typealias Dependency = AllInjectables
  private let dependency: Dependency
  init(dependency: Dependency) {
    self.dependency = dependency
  }
}
