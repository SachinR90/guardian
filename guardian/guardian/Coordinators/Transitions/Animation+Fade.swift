//
//  Animation+Fade.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import UIKit

let defaultAnimationDuration: TimeInterval = 0.35

extension CGFloat {
  static let verySmall: CGFloat = 0.0001
}

extension Animation {
  static let fade = Animation(presentation: InteractiveTransitionAnimation.fade,
                              dismissal: InteractiveTransitionAnimation.fade)
}

private extension InteractiveTransitionAnimation {
  static let fade = InteractiveTransitionAnimation(duration: defaultAnimationDuration) { transitionContext in
    let containerView = transitionContext.containerView
    let toView = transitionContext.view(forKey: .to)!

    toView.alpha = 0.0
    containerView.addSubview(toView)

    UIView.animate(withDuration: defaultAnimationDuration, delay: 0, options: [.curveLinear], animations: {
      toView.alpha = 1.0
    }, completion: { _ in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    })
  }
}
