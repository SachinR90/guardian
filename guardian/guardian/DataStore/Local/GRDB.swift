//
//  GRDB.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import GRDB

protocol CreatableTableRecord {
  static var createTableInfo: (TableDefinition) -> Void { get }
}

extension Database {
  func createTable<T: CreatableTableRecord & TableRecord>(
    _: T.Type,
    temporary: Bool = false,
    ifNotExists: Bool = false,
    withoutRowID: Bool
  ) throws {
    try create(table: T.databaseTableName, temporary: temporary, ifNotExists: ifNotExists, withoutRowID: withoutRowID, body: T.createTableInfo)
  }

  func createTable<T: CreatableTableRecord & TableRecord>(
    _ type: T.Type,
    temporary: Bool = false,
    ifNotExists: Bool = false
  )
    throws
  {
    try createTable(type, temporary: temporary, ifNotExists: ifNotExists, withoutRowID: false)
  }
}

extension PersistableRecord {
  func updateRecordIgnoringNotFoundError(_ db: Database) throws {
    do {
      try update(db)
    } catch {
      switch error {
        case GRDB.PersistenceError.recordNotFound:
          break
        default:
          throw error
      }
    }
  }
}
