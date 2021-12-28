//
//  NewsApiEndPointProvider.swift
//  guardian
//
//  Created by Sachin Rao on 18/12/21.
//

import Foundation
import Moya

struct NewsApiEndPointProvider {
  let keyProvider: ApiKeyProvider
  init(provider: ApiKeyProvider) {
    self.keyProvider = provider
  }

  func endPointClosure<Target: TargetType>(for target: Target) -> Endpoint {
    var endpoint = MoyaProvider<Target>.defaultEndpointMapping(for: target)
    endpoint = keyProvider.insertApiKey(endPoint: endpoint, target: target)
    return endpoint
  }
}
