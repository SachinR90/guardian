//
//  Observables+Extensions.swift
//  guardian
//
//  Created by Sachin Rao on 15/12/21.
//

import Foundation
import RxSwift

// MARK: DebounceFirst

extension ObservableType {
  /**
   Convenient overload for debounceFirst which has default timeSpan of 300 ms.
   */
  func debounceFirstDefault(timerScheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)) -> Observable<Element> {
    debounceFirst(timeSpan: .milliseconds(300), timerScheduler: timerScheduler)
  }

  /**
   Extension that provides debounceFirst behaviour while preserving operator chaining
   - parameter timeSpan: time interval for debounceFirst. Only first event will be emitted during this time interval
                         and subsequent events will be ignored
   - parameter timerScheduler: Scheduler on which debounce timer will run on

   */
  func debounceFirst(timeSpan: RxTimeInterval, timerScheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)) -> Observable<Element> {
    // To achieve debounce first behaviour, we open a from window upstream observable emitted elements,
    // and then we terminate resultant window observable by take first element of it which translates   into debounceFirst behaviour. Next window will only open after specified time interval.
    // Window operator also takes another parameter for closing of window called count. Since we don't want to close window based on count, we provide Int.max there.
    window(timeSpan: timeSpan, count: Int.max, scheduler: timerScheduler)
      .flatMap {
        $0.take(1)
      }
  }
}


