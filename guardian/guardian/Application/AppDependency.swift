//
//  AppDependency.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
/// Top level dependency container for the entire application.
/// It creates and holds the concrete instances of the dependencies and inject them into
/// their consumers as protocols.
final class AppDependency: AllInjectables {
  // MARK: Singletons

  lazy var networkConnectivity: Connectivity = { NetworkConnectivity.shared }()
  lazy var network: Network = { Network.newDefaultNetwork() }()
  lazy var persistenceStore: PersistenceStore = { AppDatabase() }()
  lazy var homeRespository: HomeRepositoryType = { HomeRepository(self) }()
  lazy var newsDAO: NewsDAOType = { NewsDAO() }()

  lazy var homePersistenceServiceable: HomePersistenceServiceable = {
    HomePersistenceService(self)
  }()

  // MARK: Factories

  var viewControllerProvider: ViewControllerProvider {
    ViewControllerFactory(dependency: self)
  }

  var homeViewModel: HomeViewModelType {
    HomeViewModel(self)
  }
}
