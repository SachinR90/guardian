//
//  ApplicationController.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import BackgroundTasks
import Firebase
import Foundation
import GRDB
import RxSwift
import UIKit

public func printToConsole(_ items: Any..., separator: String = " ", terminator: String = "\n") {
  #if DEBUG
  print(items, separator: separator, terminator: terminator)
  #endif
}

class ApplicationController {
  private let bgAppRefreshTaskIdentier = "com.example.guardian.backgroundAppRefreshIdentifier"
  lazy var appNavigationController = UINavigationController()
  lazy var appRouter = NavigationRouter(navigationController: appNavigationController)
  private var appCoordinator: AppCoordinator!
  private let appDependency = AppDependency()
  private final let disposeBag = DisposeBag()

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
    appDependency.userNotificationProvider.onNotificationReceived.subscribe(onNext: { _ in

    }).disposed(by: disposeBag)
    appCoordinator = AppCoordinator(router: appRouter, dependencies: appDependency)
    window?.rootViewController = appCoordinator.toPresent()
    window?.makeKeyAndVisible()
    FirebaseApp.configure()
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

    let config = Configuration()
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
    BGTaskScheduler.shared.cancelAllTaskRequests()
    BGTaskScheduler.shared.register(forTaskWithIdentifier: bgAppRefreshTaskIdentier, using: nil) { [weak self] task in
      guard let self = self else { return }
      printToConsole("BackgroundAppRefreshTaskScheduler is executed NOW!")
      printToConsole("Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)s")
      self.scheduleLocalNotification(name: "App Processing")
      task.expirationHandler = {
        task.setTaskCompleted(success: false)
      }
      self.appDependency.homeRespository.loadRemoteNews(query: "Afghanistan", page: 0) { status in
        switch status {
        case .success:
          task.setTaskCompleted(success: true)
        case .failure:
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
      printToConsole(earliestDate)
      backgroundAppRefreshTaskRequest.earliestBeginDate = earliestDate
      try BGTaskScheduler.shared.submit(backgroundAppRefreshTaskRequest)
      printToConsole("Submitted task request")
    } catch {
      printToConsole("Failed to submit BGTask: \(error) \(error.localizedDescription)")
    }
  }

  private func getNextEarliestDate() -> Date {
    let now = Date()
    let calendar = Calendar.current
    let components = DateComponents(calendar: calendar, hour: 6) // <- 06:00 = 6am
    let next6Am = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime)!
    return next6Am
  }

  private final func scheduleLocalNotification(name: String) {
    let request = appDependency.localNotificatioNContentProvider
      .setTitle(title: "Guardian App")
      .setBody(body: "Background App Refresh")
      .build()
    let pnProvider = appDependency.userNotificationProvider
    pnProvider.requestAuthorizationForNotification {
      if $0 {
        pnProvider.pushLocalNotification(with: request, nil)
      } else {
        print("\($1?.localizedDescription ?? "")")
      }
    }
  }
}
