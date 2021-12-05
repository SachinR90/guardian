//
//  AtomicObject.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation

final class AtomicObject<T> {
  private let queue = DispatchQueue(label: "Atomic serial queue")
  private var _value: T
  init(_ value: T) {
    _value = value
  }

  var value: T {
    queue.sync { self._value }
  }

  func mutate(_ transform: (inout T) -> Void) {
    queue.sync {
      transform(&self._value)
    }
  }
}
