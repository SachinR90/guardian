//
//  NewsDao.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import GRDB

protocol NewsDAOType {
  func getNewsList(db: Database) throws -> [News]
  func upsertNews(news: News, db: Database) throws
  func getNewsCount(db: Database) throws -> Int
}

class NewsDAO: NewsDAOType {
  func getNewsCount(db: Database) throws -> Int {
    try News.fetchCount(db)
  }

  func getNewsList(db: Database) throws -> [News] {
    try News.fetchAll(db).sorted { lhs, rhs in
      lhs.dateTime() > rhs.dateTime()
    }
  }

  func upsertNews(news: News, db: Database) throws {
    try news.save(db)
  }
}
