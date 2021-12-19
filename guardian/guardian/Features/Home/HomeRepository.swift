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
  func loadLocalNews(limit: Int,
                     page: Int,
                     completion: @escaping (Result<NewsResponse, Error>) -> Void)
  @discardableResult
  func loadRemoteNews(query: String, page: Int,
                      completion: @escaping (Result<NewsResponse, Error>) -> Void) -> NetworkCancellable
  func localNewsCount() throws -> Int
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

  func loadRemoteNews(query: String, page: Int, completion: @escaping (Result<NewsResponse, Error>) -> Void) -> NetworkCancellable {
    network.request(target: .getNews(query: query, page: page)) { [weak self] result in
      do {
        let newsResonse = try result.get().mapValue(NewsResponse.self)
        try self?.homePersistenceService.saveNewsList(newsResonse.results ?? [])
        completion(.success(newsResonse))
      } catch {
        completion(.failure(error))
      }
    }
  }

  func loadLocalNews(limit: Int, page: Int, completion: @escaping (Result<NewsResponse, Error>) -> Void) {
    do {
      let results = try homePersistenceService.getNewsList(limit: limit, page: page)
      let response = NewsResponse(pageSize: results.count, currentPage: page, results: results)
      completion(.success(response))
    } catch {
      completion(.failure(error))
    }
  }

  func localNewsCount() throws -> Int {
    try homePersistenceService.getNewsCount()
  }
}
