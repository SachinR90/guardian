//
//  Network.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import Moya

class Network: NetworkType {
  typealias T = NewsAPI
  let provider: MoyaProvider<NewsAPI>
  init(provider: MoyaProvider<T>) {
    self.provider = provider
  }
}

extension Network {
  static func newDefaultNetwork(
    callbackQueue: DispatchQueue? = DispatchQueue.global(qos: .utility),
    trackInflights: Bool = true
  ) -> Network {
    let networkProvider = MoyaProvider<NewsAPI>(callbackQueue: callbackQueue,
                                                session: alamofireSession(),
                                                plugins: defaultPlugins(),
                                                trackInflights: trackInflights)
    return Network(provider: networkProvider)
  }
}
