//
//  NetworkCancellable.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import Moya

class NetworkCancellable {
  private var cancellable: Cancellable?
  private var cancelled: Bool = false

  init(cancellable: Cancellable?) {
    self.cancellable = cancellable
  }

  func cancel() {
    cancellable?.cancel()
  }

  func isCancelled() -> Bool {
    cancellable?.isCancelled ?? false
  }
}
