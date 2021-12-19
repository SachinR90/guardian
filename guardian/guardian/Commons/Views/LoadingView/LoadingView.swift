//
//  LoadingView.swift
//  guardian
//
//  Created by Sachin Rao on 15/12/21.
//

import Foundation
import UIKit
class LoadingView: NibCreatableView {
  let spinnerView = JTMaterialSpinner()
  override func commonInit() {
    super.commonInit()

    let spinnerView = JTMaterialSpinner()
    containerView.addSubview(spinnerView)
    let rad = frame.width > frame.height
      ? (frame.width > 50 ? 50 : frame.width)
      : (frame.height > 50 ? 50 : frame.height)
    spinnerView.frame = CGRect(x: 0, y: 0, width: rad, height: rad)

    spinnerView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalTo(rad)
      make.height.equalTo(rad)
    }

    spinnerView.circleLayer.lineWidth = 3.0
    spinnerView.circleLayer.strokeColor = UIColor.systemBlue.cgColor
    spinnerView.beginRefreshing()
  }

  override var isHidden: Bool {
    get {
      super.isHidden
    }
    set(v) {
      super.isHidden = v
      spinnerView.endRefreshing()
    }
  }

  func showHide(hide: Bool, animated: Bool = true, duration: TimeInterval = 0.1) {
    let hideBlock = {
      self.isHidden = hide
      if hide {
        self.spinnerView.endRefreshing()
      } else {
        self.spinnerView.beginRefreshing()
      }
    }

    if animated {
      UIView.animate(withDuration: duration, animations: {
        self.alpha = hide ? 0 : 1
      }) { _ in
        hideBlock()
      }
    } else {
      hideBlock()
    }
  }
}
