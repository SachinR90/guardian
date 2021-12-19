//
//  ApiKeyProvider.swift
//  guardian
//
//  Created by Sachin Rao on 18/12/21.
//

import Foundation
import Moya

public final class ApiKeyProvider {
  typealias Dependency = SecuredDataStoreInjectable
  let secureDataStore: SecuredDataStore
  init(with dependency: Dependency) {
    self.secureDataStore = dependency.securedDataStore
  }

  func insertApiKey(endPoint: Endpoint, target: TargetType) -> Endpoint {
    guard let guardianKey = secureDataStore.getGuardianKey() else { return endPoint }
    switch target.task {
    case let .requestParameters(parameters, encoding):
      var parameters = parameters
      parameters["api_key"] = guardianKey
      return endPoint.replacing(task: .requestParameters(parameters: parameters,
                                                         encoding: encoding))
    default:
      fatalError("Could not insert parameters for request \(target.path) as the task \(target.task) is not supported.")
    }
  }
}
