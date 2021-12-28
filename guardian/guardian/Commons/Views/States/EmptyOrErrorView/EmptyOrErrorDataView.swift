//
//  EmptyOrErrorDataView.swift
//  guardian
//
//  Created by Sachin Rao on 15/12/21.
//

import Foundation
import RxSwift
import UIKit

enum EmptyDataScreenMode {
  case empty
  case error
}

class EmptyOrErrorDataView: NibCreatableView {
  @IBOutlet var messageLabel: UILabel!
  @IBOutlet var retryButton: UIButton!
  @IBOutlet var imageView: UIImageView!

  private(set) var mode: EmptyDataScreenMode = .empty

  private let disposeBag = DisposeBag()

  init(with mode: EmptyDataScreenMode = .empty) {
    self.mode = mode
    super.init(frame: .zero)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func commonInit() {
    super.commonInit()
    retryButton.isHidden = true
    applyThemeColors()
  }

  func configure(
    errorType: EmptyDataScreenMode,
    _ errorMessage: String,
    showRetry: Bool = true,
    retryAction: (() -> Void)?,
    buttonTitle: String = "Retry"
  ) {
    messageLabel.text = errorMessage

    switch errorType {
      case .empty:
        imageView.image = UIImage.remove
      case .error:
        imageView.image = UIImage.remove
    }

    if showRetry, let retryAction = retryAction {
      retryButton.rx.tap
        .debounceFirstDefault()
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: {
          retryAction()
        })
        .disposed(by: disposeBag)
      retryButton.isHidden = false
    } else {
      retryButton.isHidden = true
    }
    retryButton.setTitle(buttonTitle, for: .normal)
  }

  private func applyThemeColors() {
    messageLabel.textColor = UIColor.systemRed
    retryButton.backgroundColor = UIColor.systemFill
  }
}
