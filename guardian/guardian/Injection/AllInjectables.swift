//
//  AllInjectables.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation

/// Type alias for all types of injectables in the entire application
typealias AllInjectables =
  ViewControllerInjectable
    & NetworkInjectable
    & PersistenceInjectable
    & HomeViewModelInjectable
    & HomeRepositoryInjectable
    & NewsDAOInjectable
    & HomePersistenceServiceInjectable
    & NewsDetailsViewModelInjectable
    & RemoteConfigInjectable
    & NewsApiEndPointProviderInjectable
    & SecuredDataStoreInjectable
    & SplashViewModelInjectable
    & UserNotificationInjectable
    & LocalNotificationContentInjectable
