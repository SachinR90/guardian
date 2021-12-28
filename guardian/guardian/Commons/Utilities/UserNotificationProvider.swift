//
//  LocalNotificationProvider.swift
//  guardian
//
//  Created by Sachin Rao on 20/12/21.
//

import Foundation
import RxSwift
import UIKit
import UserNotifications
protocol UserNotificationProvidable {
  func requestAuthorizationForNotification(completionHandler: ((Bool, Error?) -> Void)?)
  func pushLocalNotification(with request: UNNotificationRequest, _ completionHandler: ((Bool, Error?) -> Void)?)
  func resetBadgeNumber()
  var onNotificationReceived: Observable<UNNotificationResponse> { get }
}

class UserNotificationProvider: NSObject, UserNotificationProvidable {
  let disposeBag = DisposeBag()
  override init() {
    super.init()
    notificationCenter.delegate = self
  }

  let options: UNAuthorizationOptions = [
    .alert,
    .sound,
    .badge,
    .criticalAlert,
    .providesAppNotificationSettings,
    .provisional,
  ]

  private let _onNotificationReceived = PublishSubject<UNNotificationResponse>()

  final var onNotificationReceived: Observable<UNNotificationResponse> {
    _onNotificationReceived.asObservable()
  }

  final var notificationCenter: UNUserNotificationCenter {
    UNUserNotificationCenter.current()
  }

  final func requestAuthorizationForNotification(completionHandler: ((Bool, Error?) -> Void)?) {
    notificationCenter.requestAuthorization(options: options) { success, error in
      completionHandler?(success, error)
//      if error == nil {
//        DispatchQueue.main.async {
//          UIApplication.shared.registerForRemoteNotifications()
//        }
//      }
    }
  }

  final func resetBadgeNumber() {
    UIApplication.shared.applicationIconBadgeNumber = 0
  }

  final func pushLocalNotification(with request: UNNotificationRequest, _ completionHandler: ((Bool, Error?) -> Void)?) {
    notificationCenter.getNotificationSettings { [weak self] settings in
      guard let self = self else {
        completionHandler?(
          false,
          NSError(domain: "Something Went Wrong", code: 1, userInfo: ["status": settings.authorizationStatus])
        )
        return
      }

      if settings.authorizationStatus == .authorized {
        // Add Request to User Notification Center
        self.notificationCenter.add(request) { error in
          completionHandler?(error == nil, error)
        }
      } else {
        completionHandler?(false, NSError(domain: "UNAuthorization Error", code: 1, userInfo: ["status": settings.authorizationStatus]))
      }
    }
  }
}

extension UserNotificationProvider: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    defer {
      completionHandler()
      center.removeDeliveredNotifications(withIdentifiers:
        [response.notification.request.identifier])
    }
    _onNotificationReceived.onNext(response)
  }
}
