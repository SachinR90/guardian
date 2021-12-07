//
//  ApplicationController.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import BackgroundTasks
import Foundation
import GRDB
import UIKit
import SQLCipher

class ApplicationController {
  private let bgAppRefreshTaskIdentier = "com.example.guardian.backgroundAppRefreshIdentifier"
  lazy var appNavigationController = UINavigationController()
  lazy var appRouter = NavigationRouter(navigationController: appNavigationController)
  private var appCoordinator: AppCoordinator!
  private let appDependency = AppDependency()

  func start(with window: UIWindow?) {
    configureAppAppearance()
    appCoordinator = AppCoordinator(router: appRouter, dependencies: appDependency)
    // Setup app data base
    do {
      _ = try setupDatabase()
    } catch {
      fatalError("Database could not setup properly.")
    }
    appDependency.networkConnectivity.startMonitoring()
    appCoordinator = AppCoordinator(router: appRouter, dependencies: appDependency)

    window?.rootViewController = appCoordinator.toPresent()
    window?.makeKeyAndVisible()

    appCoordinator.start()
    registerForBGAppRefresh()
  }

  private func configureAppAppearance() {
    UINavigationBar.appearance().barStyle = .default
    UINavigationBar.appearance().isTranslucent = false
    UINavigationBar.appearance().shadowImage = UIImage()
    if var textAttributes = UINavigationBar.appearance().titleTextAttributes {
      textAttributes[NSAttributedString.Key.foregroundColor] = UIColor.black
      UINavigationBar.appearance().titleTextAttributes = textAttributes
    }
  }
}

// MARK: SETUP DATABASE

extension ApplicationController {
  private func setupDatabase() throws -> DatabaseQueue {
    // Create a DatabasePool for efficient multi-threading
    let databaseURL = try FileManager.default
      .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      .appendingPathComponent("Guardian.sqlite.db")

    var config = Configuration()
    config.prepareDatabase { db in
      try db.usePassphrase("guardian@123")
    }
    // config.trace = { print($0) }     // Prints all SQL statements
    let dbQueue = try DatabaseQueue(path: databaseURL.path, configuration: config)

    CurrentDB = GRDBWorld(database: { dbQueue })

    // Setup the database
    try appDependency.persistenceStore.setup()

    return dbQueue
  }
}

// MARK: BGAppRefresh

extension ApplicationController {
  func registerForBGAppRefresh() {
    if UIApplication.shared.backgroundRefreshStatus != .available {
      return
    }
    BGTaskScheduler.shared.register(forTaskWithIdentifier: bgAppRefreshTaskIdentier, using: nil) { [weak self] task in
      print("BackgroundAppRefreshTaskScheduler is executed NOW!")
      print("Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)s")
      task.expirationHandler = {
        task.setTaskCompleted(success: false)
      }
      self?.appDependency.homeViewModel.refreshRemoteData { count in
        if count > 0 {
          task.setTaskCompleted(success: true)
        } else {
          task.setTaskCompleted(success: false)
        }
      }
    }
  }

  func submitTaskToBGTaskScheduler() {
    if UIApplication.shared.backgroundRefreshStatus != .available {
      return
    }
    do {
      let backgroundAppRefreshTaskRequest = BGAppRefreshTaskRequest(identifier: bgAppRefreshTaskIdentier)
      let earliestDate = getNextEarliestDate()
      print(earliestDate)
      backgroundAppRefreshTaskRequest.earliestBeginDate = earliestDate
      try BGTaskScheduler.shared.submit(backgroundAppRefreshTaskRequest)
      print("Submitted task request")
    } catch {
      print("Failed to submit BGTask: \(error) \(error.localizedDescription)")
    }
  }

  private func getNextEarliestDate() -> Date {
    let now = Date()
    let calendar = Calendar.current
    let components = DateComponents(calendar: calendar, hour: 6) // <- 06:00 = 6am
    let next6Am = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime)!
    return next6Am
  }
}
