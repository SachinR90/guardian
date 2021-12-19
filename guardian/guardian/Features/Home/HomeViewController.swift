//
//  HomeViewController.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import RxSwift
import UIKit

class HomeViewController: UIViewController, UIViewControllerStatePresentable {
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

  @IBOutlet var noNetworkLabel: PaddingLabel!
  @IBOutlet var tableView: UITableView!
  @IBOutlet var noNetworkLabelHeightConstraint: NSLayoutConstraint!
  private lazy var viewSpinner: UIView = {
    let view =
      UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 48))
    let loadingView = LoadingView(
      frame: CGRect(
        x: 0,
        y: 0,
        width: 24,
        height: 24))
    loadingView.center = view.center
    view.addSubview(loadingView)
    return view
  }()

  private var viewModel: HomeViewModelType
  private let debouncer = Debouncer(seconds: 1)
  private var refreshControl = UIRefreshControl()
  private let disposeBag = DisposeBag()

  // MARK: UIListStatePresentable

  internal var loadingStateViewController: LoadingStateViewController?

  internal var emptyStateViewController: EmptyStateViewController?

  internal var errorStateViewController: ErrorStateViewController?
  internal lazy var dataViews: [UIView] = {
    [tableView, noNetworkLabel]
  }()

  // MARK: Methods

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.enableDisableInteractivePopGesture(enabled: true)
    setupUI()
  }

  private func setupUI() {
    title = "Home"
    configureNoNetworkLabel()
    bindToViewModel()
    configureTableView()
    viewModel.initialLoad()
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
    tableView.estimatedRowHeight = 360
    tableView.rowHeight = UITableView.automaticDimension
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.dataSource = self
    tableView.delegate = self
  }

  @objc func refreshData() {
    // Fake 1 sec delay so that refresh control stays on the screen
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
      self.viewModel.resetAndRefreshData()
    }
  }

  private func bindToViewModel() {
    viewModel.onStateChange.observe(on: MainScheduler.instance).subscribe { [weak self] state in
      guard let self = self, let state = state.element else { return }
      switch state {
      case let .isLoadingMore(isLoading):
        self.tableView.tableFooterView = isLoading
          ? self.viewSpinner
          : UIView(frame: .zero)
      case let .isRefreshing(isRefreshing):
        if isRefreshing {
          self.refreshControl.beginRefreshing()
        } else {
          self.refreshControl.endRefreshing()
        }
      case let .viewState(value):
        self.render(
          from: value,
          retryBlock: {},
          onData: {
            self.tableView.reload()
            self.refreshControl.endRefreshing()
          },
          onEmpty: {
            self.refreshControl.endRefreshing()
          },
          onError: {
            self.refreshControl.endRefreshing()
          })
      case .none:
        break
      }
    }.disposed(by: disposeBag)
  }
}

extension HomeViewController {
  private func updateErrorLabel(message: String, visible: Bool) {
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.3) { () -> Void in
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

  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? NewsItemTableViewCell {
      cell.imageView?.kf.cancelDownloadTask()
      cell.imageView?.kf.setImage(with: URL(string: ""))
      cell.imageView?.image = nil
    }
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let height = scrollView.frame.size.height
    let contentYoffset = scrollView.contentOffset.y
    let distanceFromBottom = scrollView.contentSize.height - contentYoffset
    if distanceFromBottom <= height {
      viewModel.loadMore()
    }
  }
}

extension HomeViewController {
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
