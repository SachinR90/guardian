//
//  News.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import GRDB

struct News: Codable, Equatable {
  let id: String?
  let webPublicationDate: String?
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
    self.webPublicationDate = try newsContainer.decode(String.self, forKey: .webPublicationDate)
    self.webTitle = try newsContainer.decode(String.self, forKey: .webTitle)
    self.fields = try newsContainer.decode(NewsFields.self, forKey: .fields)
    self.webUrl = try newsContainer.decode(String.self, forKey: .webUrl)
  }

  func dateTime() -> Date {
    let formatter = ISO8601DateFormatter()
    return formatter.date(from: webPublicationDate!)!
  }

  func formattedDate() -> String {
    let currentFormatter = DateFormatter()
    currentFormatter.dateFormat = "dd-MMM-yyyy hh:mm a"
    return currentFormatter.string(from: dateTime())
  }
}

extension News: CreatableTableRecord {
  static var createTableInfo: (TableDefinition) -> Void = { defination in
    defination.column("id", .text).primaryKey()
    defination.column("webPublicationDate", .text)
    defination.column("webTitle", .text)
    defination.column("webUrl", .text)
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
