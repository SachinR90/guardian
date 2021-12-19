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
  func getNewsList(limit: Int, page: Int) throws -> [News]
  func getNewsCount() throws -> Int
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
      try newsDAO.getAllNews(db: db)
    }
  }

  func getNewsList(limit: Int, page: Int) throws -> [News] {
    try dbQueue.read { db in
      try newsDAO.getNewsList(limit: limit, offset: page, db: db)
    }
  }

  func saveNewsList(_ news: [News]) throws {
    try dbQueue.inTransaction { db in
      try news.forEach { newsItem in
        try newsDAO.upsertNews(news: newsItem, db: db)
      }
      return .commit
    }
  }

  func getNewsCount() throws -> Int {
    try dbQueue.read { db in
      try newsDAO.getNewsCount(db: db)
    }
  }
}
