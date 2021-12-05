//
//  PersistenceStore.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import GRDB
import UIKit

struct GRDBWorld {
  private(set) var database: () -> DatabaseQueue

  /// Creates a World with a database
  init(database: @escaping () -> DatabaseQueue) {
    self.database = database
  }
}

var CurrentDB = GRDBWorld(database: { fatalError("Database is uninitialized") })

protocol PersistenceStore {
  func setup() throws
  func dropAllRecords() throws
}

struct AppDatabase: PersistenceStore {
  func setup() throws {
    // Use DatabaseMigrator to define the database schema
    // See https://github.com/groue/GRDB.swift/#migrations
    try migrator.migrate(CurrentDB.database())

    // Other possible setup include: custom functions, collations,
    // full-text tokenizers, etc.
  }

  // Migrations
  private var migrator: DatabaseMigrator {
    var migrator = DatabaseMigrator()

    migrator.registerMigration("v1") { _ in
    }
    return migrator
  }

  func dropAllRecords() throws {
    try CurrentDB.database().inTransaction { _ in

      // Meetings
      .commit
    }
  }
}
