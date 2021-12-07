//
//  NewsDetailsViewController.swift
//  guardian
//
//  Created by Sachin Rao on 06/12/21.
//

import SnapKit
import UIKit
import WebKit

class NewsDetailsViewController: UIViewController {
  init(viewModel: NewsDetailsViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private lazy var openURlButton: UIButton = {
    let button = UIButton(type: .custom)
    button.addTarget(self, action: #selector(onPressOfOpenUrl), for: .touchUpInside)
    button.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
    button.clipsToBounds = true
    button.setTitleColor(UIColor.systemBlue, for: .normal)
    button.setTitle("Open Url", for: .normal)
    button.sizeToFit()
    return button
  }()

  private var viewModel: NewsDetailsViewModelType
  @IBOutlet var image: UIImageView!
  @IBOutlet var newsTitle: UILabel!
  @IBOutlet var newsBody: UITextView!
  @IBOutlet var dateTime: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupNavigationbarItem()
  }

  func setupUI() {
    title = viewModel.newsItem?.webTitle?.firstNWords(n: 3)
    if let url = viewModel.newsItem?.fields?.thumbnail, let uri = URL(string: url) {
      image.kf.indicatorType = .activity
      image.kf.setImage(with: uri, options: [.transition(.fade(0.2))])
    }
    image.layer.cornerRadius = 8
    image.clipsToBounds = true
    newsTitle.text = viewModel.newsItem?.webTitle
    dateTime.text = viewModel.newsItem?.formattedDate()
    newsBody.text = viewModel.newsItem?.fields?.body?.stripOutHtml()
  }

  func setupNavigationbarItem() {
    // Add right button
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: openURlButton)
  }

  @objc private func onPressOfOpenUrl() {
    viewModel.navigateToUrl()
  }
}
