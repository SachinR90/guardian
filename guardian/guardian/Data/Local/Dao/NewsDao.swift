//
//  NewsDao.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import GRDB

protocol NewsDAOType {
  func getAllNews(db: Database) throws -> [News]
  func getNewsList(limit: Int, offset: Int, db: Database) throws -> [News]
  func upsertNews(news: News, db: Database) throws
  func getNewsCount(db: Database) throws -> Int
}

class NewsDAO: NewsDAOType {
  func getNewsCount(db: Database) throws -> Int {
    try News.fetchCount(db)
  }

  func getAllNews(db: Database) throws -> [News] {
    try News.all().order(Column("webPublicationDate").desc).fetchAll(db)
  }

  func upsertNews(news: News, db: Database) throws {
    if let oldNews = try News.filter(Column("id") == news.id!).fetchOne(db) {
      try news.updateChanges(db, from: oldNews)
    }
    else {
      try news.insert(db)
    }
  }

  func getNewsList(limit: Int, offset: Int, db: Database) throws -> [News] {
    let page = (limit * offset) - limit
    let news = try News.all()
      .limit(limit, offset: page)
      .order(Column("webPublicationDate").desc)
      .fetchAll(db)
    return news
  }
}
