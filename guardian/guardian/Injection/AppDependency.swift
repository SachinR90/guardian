//
//  AppDependency.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Firebase
import Foundation
import SwiftKeychainWrapper
/// Top level dependency container for the entire application.
/// It creates and holds the concrete instances of the dependencies and inject them into
/// their consumers as protocols.
final class AppDependency: AllInjectables {
  // MARK: Singletons

  lazy var networkConnectivity: Connectivity = { NetworkConnectivity.shared }()
  lazy var network: Network = { Network.newDefaultNetwork(endpointProvider: newsApiEndPointProvider) }()
  lazy var persistenceStore: PersistenceStore = { AppDatabase() }()
  lazy var homeRespository: HomeRepositoryType = { HomeRepository(self) }()
  lazy var newsDAO: NewsDAOType = { NewsDAO() }()
  lazy var homePersistenceServiceable: HomePersistenceServiceable = {
    HomePersistenceService(self)
  }()

  lazy var remoteConfig: RemoteConfig = {
    var config = RemoteConfig.remoteConfig()
    let settings = RemoteConfigSettings()
    settings.minimumFetchInterval = 10
    settings.fetchTimeout = 30
    config.configSettings = settings
    return config
  }()

  lazy var newsApiEndPointProvider: NewsApiEndPointProvider = {
    NewsApiEndPointProvider(provider: ApiKeyProvider(with: self))
  }()

  lazy var securedDataStore: SecuredDataStore = {
    KeyChainDataStore(
      with: KeychainWrapper(
        serviceName: "com.example.guardian.keychaindata"
      ))
  }()

  // MARK: Factories

  var viewControllerProvider: ViewControllerProvider {
    ViewControllerFactory(dependency: self)
  }

  var homeViewModel: HomeViewModelType {
    HomeViewModel(self)
  }

  var newsDetailsViewModel: NewsDetailsViewModelType {
    NewsDetailsViewModel()
  }

  var splashViewModel: SplashViewModelType {
    SplashViewModel(dependency: self)
  }
}
