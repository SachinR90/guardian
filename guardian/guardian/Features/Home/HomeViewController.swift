//
//  HomeViewController.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import UIKit

class HomeViewController: UIViewController {
  init(viewModel: HomeViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(connectivityChanged(notification:)),
                                           name: .connectivityChanged, object: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @IBOutlet var spinner: UIActivityIndicatorView!
  @IBOutlet var noNetworkLabel: PaddingLabel!
  @IBOutlet var tableView: UITableView!
  @IBOutlet var noNetworkLabelHeightConstraint: NSLayoutConstraint!

  private var viewModel: HomeViewModelType
  private let debouncer = Debouncer(seconds: 1)
  private var refreshControl = UIRefreshControl()

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.enableDisableInteractivePopGesture(enabled: true)
    setupUI()
    viewModel.loadLocalData()
  }

  private func setupUI() {
    self.title = "Home"
    configureNoNetworkLabel()
    configureTableView()
    viewModel.delegate = self
  }

  private func configureNoNetworkLabel() {
    noNetworkLabel.bottomBorder = true
    noNetworkLabel.clipsToBounds = true
    let status = NetworkConnectivity.shared.currentStatus
    if status.status == .notConnected {
      let message = "You must be connected to the internet."
      updateErrorLabel(message: message, visible: true)
    }
  }

  private func configureTableView() {
    // Add refresh control
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh!")
    refreshControl.addTarget(self,
                             action: #selector(refreshData),
                             for: .valueChanged)
    tableView.addSubview(refreshControl)
    tableView.register(NewsItemTableViewCell.self)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 56
    tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    tableView.dataSource = self
    tableView.delegate = self
  }

  @objc func refreshData() {
    // Fake 1 sec delay so that refresh control stays on the screen
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
      self.viewModel.resetAndRefreshData()
    }
  }
}

extension HomeViewController {
  private func updateErrorLabel(message: String, visible: Bool) {
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.25) { () -> Void in
        self.noNetworkLabelHeightConstraint.constant = !visible ? 0 : 42
        self.noNetworkLabel.text = message
      }
    }
  }

  @objc func connectivityChanged(notification: Notification) {
    debouncer.debounce { [weak self] in
      if let connectivityStatus = notification.object as? ConnectivityStatus {
        let noConnection = connectivityStatus.status == .notConnected
        let message = noConnection ? "You must be connected to the internet." : ""
        self?.updateErrorLabel(message: message, visible: noConnection)
      }
    }
  }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.getNumberofRows()
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let newsItem = viewModel.getNews(at: indexPath.row)
    let cell = tableView.dequeueReusableCell(withIdentifier: NewsItemTableViewCell.defaultReuseIdentifier, for: indexPath) as! NewsItemTableViewCell
    cell.configure(newsItem: newsItem)
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    viewModel.showDetails(for: indexPath)
    tableView.deselectRow(at: indexPath, animated: false)
  }
}

extension HomeViewController: HomeViewModelDelegate {
  func showSpinner() {
    DispatchQueue.main.async { [weak self] in
      self?.refreshControl.isEnabled = false
      self?.spinner.isHidden = false
    }
  }

  func hideSpinner() {
    DispatchQueue.main.async { [weak self] in
      self?.refreshControl.isEnabled = true
      self?.spinner.isHidden = true
    }
  }

  func hideRefreshingControl() {
    DispatchQueue.main.async { [weak self] in
      self?.refreshControl.endRefreshing()
    }
  }

  func reloadTable() {
    DispatchQueue.main.async { [weak self] in
      self?.refreshControl.endRefreshing()
      self?.spinner.isHidden = true
      self?.tableView.reloadData()
    }
  }

  func showErrorMessage(message: String) {
    let status = NetworkConnectivity.shared.currentStatus
    if status.status == .notConnected {
      let message = "You must be connected to the internet."
      updateErrorLabel(message: message, visible: true)
    } else {
      updateErrorLabel(message: message, visible: true)
    }
  }

  func hideErrorMessage() {
    let status = NetworkConnectivity.shared.currentStatus
    if status.status == .notConnected {
      let message = "You must be connected to the internet."
      updateErrorLabel(message: message, visible: true)
    } else {
      updateErrorLabel(message: "", visible: false)
    }
  }
}
