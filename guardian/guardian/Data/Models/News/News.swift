//
//  News.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import GRDB

struct News: Codable {
  let id: String?
  let webPublicationDate: Date?
  let webTitle: String?
  let webUrl: String?
  let fields: NewsFields?

  enum NewsKeys: String, CodingKey {
    case id
    case webPublicationDate
    case webTitle
    case webUrl
    case fields
  }

  init(from decoder: Decoder) throws {
    let newsContainer = try decoder.container(keyedBy: NewsKeys.self)
    self.id = try newsContainer.decode(String.self, forKey: .id)
    let dateString = try newsContainer.decode(String.self, forKey: .webPublicationDate)
    let formatter = DateFormatters.instance.getIsoFormatter()
    self.webPublicationDate = formatter.date(from: dateString)!
    self.webTitle = try newsContainer.decode(String.self, forKey: .webTitle)
    self.fields = try newsContainer.decode(NewsFields.self, forKey: .fields)
    self.webUrl = try newsContainer.decode(String.self, forKey: .webUrl)
  }

  init(row: Row) {
    self.id = row["id"]
    self.webPublicationDate = row["webPublicationDate"]
    self.webTitle = row["webTitle"]
    self.webUrl = row["webUrl"]
    self.fields = NewsFields(body: row["body"], thumbnail: row["thumbnail"])
  }

  func dateTime() -> Date {
    webPublicationDate!
  }

  func formattedDate() -> String {
    let currentFormatter = DateFormatters.instance.getFormatter(for: DateFormatters.DD_MMM_YYYY_HH_MM_A)
    return currentFormatter.string(from: webPublicationDate!)
  }
}

extension News: CreatableTableRecord {
  static var createTableInfo: (TableDefinition) -> Void = { defination in
    defination.column("id", .text)
    defination.column("webPublicationDate", .datetime)
    defination.column("webTitle", .text)
    defination.column("webUrl", .text)
    defination.primaryKey(["id", "webPublicationDate"])
    NewsFields.createTableInfo(defination)
  }
}

// from db
extension News: FetchableRecord {}

// to db
extension News: PersistableRecord {
  static var databaseTableName: String = "News"
  func encode(to container: inout PersistenceContainer) {
    fields?.encode(to: &container)
    container["id"] = id
    container["webPublicationDate"] = webPublicationDate
    container["webTitle"] = webTitle
    container["webUrl"] = webUrl
  }
}

extension News: Equatable, Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(webPublicationDate)
  }

  static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id && lhs.webPublicationDate == rhs.webPublicationDate
  }
}
