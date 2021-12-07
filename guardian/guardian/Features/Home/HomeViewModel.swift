//
//  HomeViewModel.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import RxSwift

protocol HomeViewModelType {
  func getNumberofRows() -> Int
  func getNews(at index: Int) -> News
  var delegate: HomeViewModelDelegate? { get set }
  @discardableResult func refreshRemoteData(completion: ((Int) -> Void)?) -> Bool
  func showDetails(for indexPath: IndexPath)
  var coordinatorDelegate: HomeCoordinatorDelegate? { get set }
  func resetAndRefreshData()
  func loadLocalData()
}

protocol HomeViewModelDelegate: AnyObject {
  func showSpinner()
  func hideSpinner()
  func hideRefreshingControl()
  func reloadTable()
  func showErrorMessage(message: String)
  func hideErrorMessage()
}

class HomeViewModel: HomeViewModelType {
  init(_ dependency: Dependency) {
    self.dependency = dependency
    repository = dependency.homeRespository
  }

  deinit {
    newsDisposable?.dispose()
  }

  typealias Dependency =
    HomeRepositoryInjectable

  // MARK: Private Members

  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private let repository: HomeRepositoryType
  private var newsDisposable: Disposable?
  private var newsList = [News]()

  weak var delegate: HomeViewModelDelegate?
  weak var coordinatorDelegate: HomeCoordinatorDelegate?
  private let rateLimiter = RateLimiter(timeInterval: 5)
  private let networkRequestDecisionPolicy = NetworkRequestDecisionPolicy()

  // MARK: Private Methods

  private func newsAtIndexPath(indexPath: IndexPath) -> News? {
    newsList[safeIndex: indexPath.row]
  }

  // MARK: Public Methods

  func getNumberofRows() -> Int {
    newsList.count
  }

  func getNews(at index: Int) -> News {
    newsList[index]
  }

  func showDetails(for indexPath: IndexPath) {
    guard let newsItem = newsAtIndexPath(indexPath: indexPath) else { return }
    coordinatorDelegate?.showDetails(for: newsItem)
  }

  func loadLocalData() {
    delegate?.showSpinner()
    resetAndRefreshData()
  }

  func resetAndRefreshData() {
    networkRequestDecisionPolicy.reset()
    rateLimiter.reset()

    newsDisposable?.dispose()
    newsDisposable = nil

    // Start local data observation
    startLocalNewsObservation()
  }

  private func startLocalNewsObservation() {
    // Start observation only if we are not already doing it
    guard newsDisposable == nil else { return }

    newsDisposable = repository
      .observerLocalNewsData()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] newsData in
        guard let strongSelf = self else { return }
        strongSelf.localDataPostProcessing(newsData: newsData)
      }, onError: { [weak self] error in
        self?.handleError(error)
      })
    newsDisposable?.disposed(by: disposeBag)
  }

  private func localDataPostProcessing(newsData: [News]) {
    if newsList != newsData {
      newsList = newsData
    }
    if newsData.isEmpty {
      makeBlockingRemoteCall { [weak self] remoteCount in
        if remoteCount == 0 {
          self?.handleEmptyData()
          self?.delegate?.hideSpinner()
          self?.delegate?.hideRefreshingControl()
        }
      }
    } else {
      delegate?.reloadTable()
      delegate?.hideSpinner()
      delegate?.hideRefreshingControl()
      delegate?.hideErrorMessage()
    }

    // Make the remote API request only for the first time
    networkRequestDecisionPolicy.execute {
      refreshRemoteData()
    }
  }

  private func makeBlockingRemoteCall(completion: ((Int) -> Void)?) {
    // Make the remote API request only for the first time
    let isRequestExecuted = networkRequestDecisionPolicy.execute {
      if !refreshRemoteData(completion: completion) { returnDBCount() }
    }

    if !isRequestExecuted {
      returnDBCount()
    }

    func returnDBCount() {
      // Get the count from the DB and return
      do {
        let dbCount = try repository.localTotalCountOfAllNews()
        completion?(dbCount)
      } catch {
        handleError(error)
      }
    }
  }

  /// allows us to enable to deal with annoying warnings or underscore replacements.
  /// to handle scenarios in which you sometimes want to
  /// ignore the return value while in other cases you want to know the return value
  @discardableResult
  func refreshRemoteData(completion: ((Int) -> Void)? = nil) -> Bool {
    rateLimiter.execute { [weak self] in
      guard let self = self else { return }
      if newsList.isEmpty {
        delegate?.hideErrorMessage()
      }
      self.startRemoteLoading(completion: completion)
    }
  }

  private func startRemoteLoading(completion: ((Int) -> Void)? = nil) {
    repository.loadRemoteNews(query: "Afghanistan") { [weak self] result in
      guard let self = self else { return }
      switch result {
        case let .success(count):
          completion?(count)
        case let .failure(error):
          // Change the state to error with appropriate message
          self.rateLimiter.reset()
          self.handleError(error)
      }
    }
  }
}

// MARK: Error/Empty State Handling

extension HomeViewModel {
  private func handleError(_ error: Error) {
    delegate?.hideSpinner()
    delegate?.hideRefreshingControl()
    switch error {
      case let ApiError.error422(message: message):
        handleEmptyData(message: message)
      default:
        DispatchQueue.main.async {
          self.delegate?.showErrorMessage(message: error.localizedDescription)
        }
    }
  }

  private func handleEmptyData(message: String? = nil) {
    DispatchQueue.main.async {
      let message = message ?? "No News Found"
      self.delegate?.showErrorMessage(message: message)
    }
  }
}
