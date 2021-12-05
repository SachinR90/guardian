//
//  RateLimiter.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
final class RateLimiter {
  private var lastExecutionDate = AtomicObject<Date>(Date.distantPast)
  private let timeIntervalBetweenExecutions: TimeInterval

  init(timeInterval: TimeInterval = 900) {
    timeIntervalBetweenExecutions = timeInterval
  }

  @discardableResult
  func execute(block: () -> Void) -> Bool {
    let timeSinceLastExecution = Date() - lastExecutionDate.value
    guard timeSinceLastExecution > timeIntervalBetweenExecutions else { return false }

    lastExecutionDate.mutate {
      $0 = Date()
    }
    block()
    return true
  }

  func reset() {
    lastExecutionDate.mutate {
      $0 = Date.distantPast
    }
  }
}
