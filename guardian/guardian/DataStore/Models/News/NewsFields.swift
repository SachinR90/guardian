//
//  NewsFields.swift
//  guardian
//
//  Created by Sachin Rao on 06/12/21.
//

import Foundation
import GRDB
struct NewsFields: Codable, Equatable {
  let body: String?
  let thumbnail: String?
}

extension NewsFields: CreatableTableRecord {
  static var createTableInfo: (TableDefinition) -> Void = { table in
    table.column("body", .text)
    table.column("thumbnail", .text)
  }
}

// From db
extension NewsFields: FetchableRecord {}

// To db
extension NewsFields: PersistableRecord {}
