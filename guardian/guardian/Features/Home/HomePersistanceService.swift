//
//  HomePersistanceService.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import GRDB
import RxGRDB
import RxSwift

protocol HomePersistenceServiceable {
  func saveNewsList(_ news: [News]) throws
  func getNewsList() throws -> [News]
  func localNewsObservable() -> Observable<[News]>
  func totalCountOfAllNews() throws -> Int
}

struct HomePersistenceService: HomePersistenceServiceable {
  init(_ dependency: Dependency) {
    dbQueue = CurrentDB.database()
    newsDAO = dependency.newsDAO
  }

  typealias Dependency = NewsDAOInjectable
  private let dbQueue: DatabaseQueue
  private let newsDAO: NewsDAOType

  func getNewsList() throws -> [News] {
    try dbQueue.read { db in
      try newsDAO.getNewsList(db: db)
    }
  }

  func saveNewsList(_ news: [News]) throws {
    try dbQueue.write { db in
      try news.forEach { newsItem in
        try newsDAO.upsertNews(news: newsItem, db: db)
      }
    }
  }

  func localNewsObservable() -> Observable<[News]> {
    ValueObservation.tracking { db -> [News] in
      try self.newsDAO.getNewsList(db: db)
    }.rx.observe(in: dbQueue).asObservable()
  }

  func totalCountOfAllNews() throws -> Int {
    try dbQueue.read { db in
      try News.fetchCount(db)
    }
  }
}
