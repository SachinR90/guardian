//
//  AppLevelInjectables.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Firebase
import Foundation

protocol ViewControllerInjectable { var viewControllerProvider: ViewControllerProvider { get }}
protocol NetworkInjectable { var network: Network { get } }
protocol PersistenceInjectable { var persistenceStore: PersistenceStore { get } }
protocol RemoteConfigInjectable { var remoteConfig: RemoteConfig { get }}
protocol NewsApiEndPointProviderInjectable { var newsApiEndPointProvider: NewsApiEndPointProvider { get } }
protocol SecuredDataStoreInjectable { var securedDataStore: SecuredDataStore { get set } }
