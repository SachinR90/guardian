//
//  HomeRepository.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import Moya
import RxSwift

protocol HomeRepositoryType {
  func observerLocalNewsData() -> Observable<[News]>
  @discardableResult
  func loadRemoteNews(query:String,completion: @escaping (Result<Int, Error>) -> Void) -> NetworkCancellable
  func localTotalCountOfAllNews() throws -> Int
}

class HomeRepository: HomeRepositoryType {
  init(_ dependency: Dependency) {
    homePersistenceService = dependency.homePersistenceServiceable
    network = dependency.network
  }

  typealias Dependency = HomePersistenceServiceInjectable
    & NetworkInjectable

  private let homePersistenceService: HomePersistenceServiceable
  private let network: Network

  func observerLocalNewsData() -> Observable<[News]> {
    homePersistenceService.localNewsObservable()
  }

  func loadRemoteNews(query:String,completion: @escaping (Result<Int, Error>) -> Void) -> NetworkCancellable {
    network.request(target: .getNews(query: query)) { [weak self] result in
      do {
        let newsResonse = try result.get().mapValue(NewsResponse.self)
        try self?.homePersistenceService.saveNewsList(newsResonse.results ?? [])
        completion(.success(newsResonse.results?.count ?? 0))
      } catch {
        completion(.failure(error))
      }
    }
  }

  func localTotalCountOfAllNews() throws -> Int {
    try homePersistenceService.totalCountOfAllNews()
  }
}
