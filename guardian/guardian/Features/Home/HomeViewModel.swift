//
//  HomeViewModel.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import GRDB
import RxCocoa
import RxSwift
enum HomeViewState: Equatable {
  case none
  case viewState(_ value: UIViewControllerState)
  case isRefreshing(_ value: Bool)
  case isLoadingMore(_ value: Bool)
}

protocol HomeViewModelType {
  // tableViewMethods
  func getNumberofRows() -> Int
  func getNews(at index: Int) -> News
  func showDetails(for indexPath: IndexPath)

  var onStateChange: Observable<HomeViewState> { get }

  var onShowDetailEvent: Observable<News> { get }

  // use this for pull to refresh
  func resetAndRefreshData()

  // load resources
  func initialLoad()
  func loadMore()
}

class HomeViewModel: HomeViewModelType {
  init(_ dependency: Dependency) {
    self.dependency = dependency
    repository = dependency.homeRespository
  }

  deinit {
    cancellableRequest?.cancel()
    cancellableRequest = nil
    newsDisposable?.dispose()
  }

  typealias Dependency = HomeRepositoryInjectable

  // MARK: Private Members

  private final let query = "Afghanistan"
  private final let dbPageLimit = 20
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private let repository: HomeRepositoryType
  private var newsDisposable: Disposable?
  private let _onStateChange = BehaviorRelay<HomeViewState>(value: .none)
  private let _onShowDetailsEvent = PublishSubject<News>()
  private var cancellableRequest: NetworkCancellable?

  // MARK: MEMBERS

  var newsItem: [News] = []

  var currentDBPage: Int = 1
  var currentNetworkPage: Int = 1

  var onStateChange: Observable<HomeViewState> {
    _onStateChange.asObservable()
  }

  var onShowDetailEvent: Observable<News> {
    _onShowDetailsEvent.asObservable()
  }

  func getNumberofRows() -> Int {
    newsItem.count
  }

  func getNews(at index: Int) -> News {
    newsItem[index]
  }

  func showDetails(for indexPath: IndexPath) {
    _onShowDetailsEvent.onNext(getNews(at: indexPath.row))
  }

  func resetAndRefreshData() {
    currentDBPage = 1
    currentNetworkPage = 1
    _onStateChange.accept(.isRefreshing(true))
    cancellableRequest = fetchFromNetwork(query: query, page: currentNetworkPage) { [weak self] remoteData in
      guard let strongSelf = self else { return }
      strongSelf.cancellableRequest?.cancel()
      strongSelf.cancellableRequest = nil
      switch remoteData {
      case let .success(networkPair):
        if networkPair.hasData {
          // load from db
          strongSelf.fetchFromLocal(limit: strongSelf.dbPageLimit, page: strongSelf.currentDBPage) { [weak self] localData in
            guard let strongSelf = self else { return }
            switch localData {
            case let .success(localPair):
              strongSelf.newsItem = localPair.response.results ?? []
              strongSelf._onStateChange.accept(.viewState(.data))
              strongSelf.currentDBPage += 1
              strongSelf.currentNetworkPage += 1
            case .failure:
              strongSelf._onStateChange.accept(.viewState(.error(message: "Something went wrong")))
            }
            strongSelf.hideLoaders()
          }
        } else {
          // no data found
          strongSelf._onStateChange.accept(.viewState(.empty(message: "No Data found.")))
          strongSelf.hideLoaders()
        }
      case let .failure(error):
        strongSelf._onStateChange.accept(.viewState(.error(message: error.localizedDescription)))
        strongSelf.hideLoaders()
      }
    }
  }

  func initialLoad() {
    _onStateChange.accept(.viewState(.loading))
    fetchFromLocal(limit: dbPageLimit, page: currentDBPage) { [weak self] localData in
      guard let strongSelf = self else { return }
      switch localData {
      case let .success(localPair):
        if localPair.hasData {
          strongSelf.newsItem.appendDistinct(contentsOf: localPair.response.results ?? []) { $0 != $1 }
          strongSelf.newsItem.sort { $0.dateTime() > $1.dateTime() }
          strongSelf._onStateChange.accept(.viewState(.data))
          strongSelf.currentDBPage += 1
          strongSelf.hideLoaders()
        } else {
          if strongSelf.cancellableRequest != nil { return }
          strongSelf.cancellableRequest = strongSelf.fetchFromNetwork(query: strongSelf.query, page: strongSelf.currentNetworkPage) { [weak self] networkData in
            guard let strongSelf = self else { return }
            switch networkData {
            case let .success(networkPair):
              if networkPair.hasData {
                strongSelf.newsItem.appendDistinct(contentsOf: networkPair.response.results?.prefix(upTo: 20) ?? []) { $0 != $1 }
                strongSelf.newsItem.sort { $0.dateTime() > $1.dateTime() }
                strongSelf._onStateChange.accept(.viewState(.data))
                strongSelf.currentDBPage += 1
                strongSelf.currentNetworkPage += 1
              }
            case .failure:
              printToConsole("something went wrong.")
            }
            strongSelf.cancellableRequest?.cancel()
            strongSelf.cancellableRequest = nil
            strongSelf.hideLoaders()
          }
        }
      case .failure:
        printToConsole("something went wrong.")
        strongSelf.hideLoaders()
      }
    }
  }

  func loadMore() {
    if _onStateChange.value == .isLoadingMore(true) {
      return
    }
    _onStateChange.accept(.isLoadingMore(true))
    fetchFromLocal(limit: dbPageLimit, page: currentDBPage) { [weak self] localData in
      guard let strongSelf = self else { return }
      switch localData {
      case let .success(localPair):
        if localPair.hasData {
          strongSelf.newsItem.appendDistinct(contentsOf: localPair.response.results ?? []) { $0 != $1 }
          strongSelf.newsItem.sort { $0.dateTime() > $1.dateTime() }
          strongSelf.currentDBPage += 1
          strongSelf._onStateChange.accept(.viewState(.data))
        } else {
          // get from network
          if strongSelf.cancellableRequest != nil {
            return
          }
          strongSelf.cancellableRequest = strongSelf.fetchFromNetwork(query: strongSelf.query, page: strongSelf.currentNetworkPage) { [weak self] networkData in
            guard let strongSelf = self else { return }
            strongSelf.cancellableRequest?.cancel()
            strongSelf.cancellableRequest = nil
            switch networkData {
            case let .success(networkPair):
              if networkPair.hasData {
                strongSelf.newsItem.appendDistinct(contentsOf: networkPair.response.results?.prefix(upTo: strongSelf.dbPageLimit) ?? []) { $0 != $1 }
                strongSelf.newsItem.sort { $0.dateTime() > $1.dateTime() }
                strongSelf._onStateChange.accept(.viewState(.data))
                strongSelf.currentDBPage += 1
                strongSelf.currentNetworkPage += 1
              }
            case .failure:
              printToConsole("something went wrong.")
            }
            strongSelf.hideLoaders()
          }
        }
      case .failure:
        printToConsole("something went wrong.")
        strongSelf.hideLoaders()
      }
    }
  }

  // MARK: Private Methods

  private func newsAtIndexPath(indexPath: IndexPath) -> News? {
    newsItem[safeIndex: indexPath.row]
  }

  private func fetchFromLocal(limit: Int, page: Int, completion: @escaping (Result<(response: NewsResponse, hasData: Bool), Error>) -> Void) {
    // get from db
    repository.loadLocalNews(limit: limit, page: page) { dbRespose in
      switch dbRespose {
      case let .success(localResponse):
        completion(
          .success((
            response: localResponse,
            hasData: (localResponse.pageSize ?? 0) > 0
          ))
        )
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  @discardableResult
  private func fetchFromNetwork(query: String, page: Int, completion: @escaping (Result<(response: NewsResponse, hasData: Bool), Error>) -> Void) -> NetworkCancellable {
    repository.loadRemoteNews(query: query, page: page) { response in
      switch response {
      case let .success(newsResponse):
        completion(
          .success((
            response: newsResponse,
            hasData: (newsResponse.results?.count ?? 0) > 0
          ))
        )
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  private func hideLoaders() {
    _onStateChange.accept(.isLoadingMore(false))
    _onStateChange.accept(.isRefreshing(false))
  }
}
