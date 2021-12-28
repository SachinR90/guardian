//
//  SplashViewController.swift
//  guardian
//
//  Created by Sachin Rao on 18/12/21.
//

import Firebase
import RxSwift
import UIKit

class SplashViewController: UIViewController {
  init(viewModel: SplashViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Outlets

  @IBOutlet var btnRetry: UIButton!
  @IBOutlet var lblError: PaddingLabel!
  @IBOutlet var btnRetryHeightConstraint: NSLayoutConstraint!
  @IBOutlet var lblErrorHeightConstraint: NSLayoutConstraint!

  // MARK: Private members

  private let viewModel: SplashViewModelType
  private let disposeBag = DisposeBag()

  // MARK: overridden function

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUi()
    bindViewModel()
    loadConfig()
  }

  // MARK: Private methods

  private final func setupUi() {
    lblError.layer.cornerRadius = 8
    lblError.clipsToBounds = true
  }

  private final func bindViewModel() {
    viewModel.onStateChange.observe(on: MainScheduler.instance).subscribe(
      onNext: { [weak self] state in
        guard let self = self else { return }
        switch state {
        case .none:
          self.noErrorState()
        case let .error(message):
          self.errorState(with: message)
        }
      }).disposed(by: disposeBag)
  }

  private final func noErrorState() {
    btnRetryHeightConstraint.constant = 0
    lblErrorHeightConstraint.constant = 0
  }

  private final func errorState(with message: String?) {
    btnRetryHeightConstraint.constant = 40
    lblError.text = message
    lblError.sizeToFit()
    lblErrorHeightConstraint.constant = lblError.intrinsicContentSize.height
  }

  private final func loadConfig() {
    viewModel.loadRemoteConfig()
  }

  @IBAction final func onClickOfBtnRetry(_ sender: Any) {
    loadConfig()
  }
}
