//
//  Animation+SideBySide.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

extension Animation {
  static let sideBySide = Animation(presentation: InteractiveTransitionAnimation.sideBySide(true, .left),
                                    dismissal: InteractiveTransitionAnimation.sideBySide(true, .right))

  static let slideOver = Animation(presentation: InteractiveTransitionAnimation.sideBySide(false, .left),
                                   dismissal: InteractiveTransitionAnimation.sideBySide(false, .right))
}

// Shamelessly copied from https://medium.com/chili-labs/custom-navigation-transitions-f791ff0a46aa
extension InteractiveTransitionAnimation {
  enum PushTransitionDirection {
    case left
    case right
  }

  fileprivate static let sideBySide = { (slide: Bool, direction: PushTransitionDirection) in
    InteractiveTransitionAnimation(duration: defaultAnimationDuration) { transitionContext in
      guard let fromView = transitionContext.view(forKey: .from) else { return }
      guard let toView = transitionContext.view(forKey: .to) else { return }

      let containerView = transitionContext.containerView

      let width = fromView.frame.size.width
      let centerFrame = CGRect(x: 0, y: 0, width: width, height: fromView.frame.height)
      let completeLeftFrame = CGRect(x: -width, y: 0, width: width, height: fromView.frame.height)
      let completeRightFrame = CGRect(x: width, y: 0, width: width, height: fromView.frame.height)

      switch direction {
        case .left:
          containerView.addSubview(toView)
          toView.frame = completeRightFrame
        case .right:
          containerView.insertSubview(toView, belowSubview: fromView)
          if slide {
            toView.frame = completeLeftFrame
          }
      }

      toView.layoutIfNeeded()

      let animations: (() -> Void) = {
        switch direction {
          case .left:
            if slide {
              fromView.frame = completeLeftFrame
            }
          case .right:
            fromView.frame = completeRightFrame
        }

        toView.frame = centerFrame
      }

      let completion: ((Bool) -> Void) = { _ in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      }

      if transitionContext.isInteractive, direction == .right {
        regular(animations, duration: 0.5, completion: completion)
      } else {
        spring(animations, duration: 0.5, completion: completion)
      }
    }
  }

  static func spring(_ animations: @escaping (() -> Void), duration: TimeInterval, completion: ((Bool) -> Void)?) {
    UIView.animate(withDuration: duration,
                   delay: 0,
                   usingSpringWithDamping: 0.9,
                   initialSpringVelocity: 0.1,
                   options: .allowUserInteraction,
                   animations: animations, completion: completion)
  }

  static func regular(_ animations: @escaping (() -> Void), duration: TimeInterval, completion: ((Bool) -> Void)?) {
    UIView.animate(withDuration: duration, animations: animations, completion: completion)
  }
}
