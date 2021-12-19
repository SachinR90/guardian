//
//  Debouncer.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

public class Debouncer {
  private var queue = DispatchQueue.global(qos: .background)

  private var job = DispatchWorkItem(block: {})
  private var previousRun = Date.distantPast
  private var maxMilliSecondsInterval: Double

  init(seconds: Int) {
    maxMilliSecondsInterval = Double(seconds) * 1000
  }

  init(milliseconds: Double) {
    maxMilliSecondsInterval = milliseconds
  }

  func onMainQueue() -> Debouncer {
    queue = DispatchQueue.main
    return self
  }

  func debounce(block: @escaping () -> Void) {
    job.cancel()
    job = DispatchWorkItem {
      block()
    }
    queue.asyncAfter(deadline: .now() + maxMilliSecondsInterval / 1000, execute: job)
  }
}

public class DebouncerFirst {
  private var queue = DispatchQueue.global(qos: .background)
  private var previousRun = Date.distantPast
  private var maxMilliSecondsInterval: Double

  init(seconds: Int) {
    maxMilliSecondsInterval = Double(seconds) * 1000
  }

  init(milliseconds: Double) {
    maxMilliSecondsInterval = milliseconds
  }

  func onMainQueue() -> DebouncerFirst {
    queue = DispatchQueue.main
    return self
  }

  func debounce(block: @escaping () -> Void) {
    // Check if the last operation happend maxMilliSecondsInterval ago or not
    // If yes then ignore the block
    // If No then queue the block
    if Date.seconds(from: previousRun) >= maxMilliSecondsInterval / 1000 {
      let job = DispatchWorkItem {
        block()
      }
      previousRun = Date()
      queue.async(execute: job)
    }
  }
}
