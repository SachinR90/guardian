//
//  ApplicationController.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import UIKit
import GRDB
import Foundation

class ApplicationController {
  lazy var appNavigationController = UINavigationController()
  lazy var appRouter = NavigationRouter(navigationController: appNavigationController)
  private var appCoordinator: AppCoordinator!
    private let appDependency = AppDependency()

  func start(with window: UIWindow?) {
    configureAppAppearance()
    appCoordinator = AppCoordinator(router: appRouter,dependencies: appDependency)
    // Setup app data base
    do {
      _ = try setupDatabase()
    } catch {
      fatalError("Database could not setup properly.")
    }
    
    window?.rootViewController = appCoordinator.toPresent()
    window?.makeKeyAndVisible()

    appCoordinator.start()
  }

  private func configureAppAppearance() {
    UINavigationBar.appearance().barStyle = .black
    UINavigationBar.appearance().isTranslucent = false
    UINavigationBar.appearance().shadowImage = UIImage()
  }
}
extension ApplicationController{
    private func setupDatabase() throws -> DatabaseQueue {
      // Create a DatabasePool for efficient multi-threading
      let databaseURL = try FileManager.default
        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent("Guardian.sqlite.db")

      let config = Configuration()
      // config.trace = { print($0) }     // Prints all SQL statements
      let dbQueue = try DatabaseQueue(path: databaseURL.path, configuration: config)

      CurrentDB = GRDBWorld(database: { dbQueue })

      // Setup the database
      try appDependency.persistenceStore.setup()

      return dbQueue
    }
}
