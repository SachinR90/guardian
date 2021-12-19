//
//  EmptyStateViewController.swift
//  guardian
//
//  Created by Sachin Rao on 15/12/21.
//

import Foundation
import UIKit
open class EmptyStateViewController: UIViewController {
  private var emptyDataView: EmptyOrErrorDataView
  private let message: String

  init(with message: String) {
    emptyDataView = EmptyOrErrorDataView()
    self.message = message
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    configureEmptyView()
  }

  open func configureEmptyView() {
    emptyDataView.configure(errorType: emptyDataView.mode, message, showRetry: false, retryAction: nil)

    view.addSubview(emptyDataView)
    emptyDataView.backgroundColor = UIColor.white
    setupEmptyViewConstraints()
  }

  private func setupEmptyViewConstraints() {
    emptyDataView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.trailing.bottom.equalTo(view)
    }
  }
}
