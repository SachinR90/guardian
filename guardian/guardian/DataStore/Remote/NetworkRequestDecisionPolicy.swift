//
//  NetworkRequestDecisionPolicy.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation

final class NetworkRequestDecisionPolicy {
  private var remoteDataLoadedAfterFirstDBFetch = AtomicObject<Bool>(false)

  var shouldProceed: Bool {
    !remoteDataLoadedAfterFirstDBFetch.value
  }

  @discardableResult
  func execute(block: () -> Void) -> Bool {
    guard shouldProceed else { return false }

    remoteDataLoadedAfterFirstDBFetch.mutate { $0 = true }
    block()
    return true
  }

  func reset() {
    remoteDataLoadedAfterFirstDBFetch.mutate { $0 = false }
  }
}
