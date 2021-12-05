//
//  AppDelegate.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import CoreData
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  private let appController = ApplicationController()
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    appController.start(with: window)
    return true
  }
}
