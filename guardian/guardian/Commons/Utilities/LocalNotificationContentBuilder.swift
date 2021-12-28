//
//  LocalNotificationContentBuilder.swift
//  guardian
//
//  Created by Sachin Rao on 24/12/21.
//

import UserNotifications

protocol LocalNotifcationContentBuildable {
  func setTitle(title: String) -> LocalNotifcationContentBuildable
  func setBody(body: String) -> LocalNotifcationContentBuildable
  func setTrigger(trigger: UNNotificationTrigger) -> LocalNotifcationContentBuildable
  func setNotificationIdentifier(id: String) -> LocalNotifcationContentBuildable
  func setSound(sound: UNNotificationSound) -> LocalNotifcationContentBuildable
  func build() -> UNNotificationRequest
}

final class LocalNotificationContentBuilder: LocalNotifcationContentBuildable {
  init() {
    content = UNMutableNotificationContent()
  }

  final let content: UNMutableNotificationContent
  final weak var trigger: UNNotificationTrigger?
  final var id: String = ""

  // MARK: Builder Methods

  final func setTitle(title: String) -> LocalNotifcationContentBuildable {
    content.title = title
    return self
  }

  final func setBody(body: String) -> LocalNotifcationContentBuildable {
    content.body = body
    return self
  }

  final func setTrigger(trigger: UNNotificationTrigger) -> LocalNotifcationContentBuildable {
    self.trigger = trigger
    return self
  }

  final func setNotificationIdentifier(id: String) -> LocalNotifcationContentBuildable {
    self.id = id
    return self
  }

  final func setSound(sound: UNNotificationSound) -> LocalNotifcationContentBuildable {
    content.sound = sound
    return self
  }

  final func build() -> UNNotificationRequest {
    // Create Notification Content
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    return request
  }
}
