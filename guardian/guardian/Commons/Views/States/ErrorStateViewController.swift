//
//  ErrorStateViewController.swift
//  guardian
//
//  Created by Sachin Rao on 15/12/21.
//

import Foundation
import UIKit

open class ErrorStateViewController: UIViewController {
  private var errorDataView: EmptyOrErrorDataView
  var message: String
  var retryAction: (() -> Void)?
  var buttonTitle: String

  init(
    with message: String,
    retryAction: (() -> Void)?,
    buttonTitle: String,
    errorDataView: EmptyOrErrorDataView = EmptyOrErrorDataView(with: .error)
  ) {
    self.message = message
    self.retryAction = retryAction
    self.buttonTitle = buttonTitle
    self.errorDataView = errorDataView
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    configureErrorView()
  }

  open func configureErrorView() {
    errorDataView.configure(errorType: errorDataView.mode,
                            message,
                            showRetry: true,
                            retryAction: retryAction,
                            buttonTitle: buttonTitle)

    view.addSubview(errorDataView)
    errorDataView.backgroundColor = UIColor.systemBackground
    setupErrorViewConstraints()
  }

  private func setupErrorViewConstraints() {
    errorDataView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.trailing.bottom.equalTo(view)
    }
  }
}
