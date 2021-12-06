//
//  HomeViewInjectables.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
protocol HomeViewModelInjectable { var homeViewModel: HomeViewModelType { get } }
protocol HomeRepositoryInjectable { var homeRespository: HomeRepositoryType { get } }
protocol NewsDAOInjectable { var newsDAO: NewsDAOType { get } }
protocol HomePersistenceServiceInjectable {
  var homePersistenceServiceable: HomePersistenceServiceable { get }
}

protocol NewsDetailsViewModelInjectable {
  var newsDetailsViewModel: NewsDetailsViewModelType { get }
}
