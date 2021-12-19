//
//  LoadingStateViewController.swift
//  guardian
//
//  Created by Sachin Rao on 15/12/21.
//

import Foundation
import UIKit

open class LoadingStateViewController: UIViewController {
  private var loadingView: LoadingView!

  override open func viewDidLoad() {
    super.viewDidLoad()
    setupLoadingView()
  }

  private func setupLoadingView() {
    loadingView = LoadingView()
    view.addSubview(loadingView)
    setupLoadingViewConstraints()
  }

  private func setupLoadingViewConstraints() {
    loadingView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }
}
