//
//  SplashViewModel.swift
//  guardian
//
//  Created by Sachin Rao on 18/12/21.
//

import Firebase
import Foundation
import RxCocoa
import RxSwift
import SwiftKeychainWrapper

enum SplashViewState: Equatable {
  case none
  case error(message: String?)
}

protocol SplashViewModelType {
  func loadRemoteConfig()
  var onStateChange: Observable<SplashViewState> { get }
  var onSplashCompleted: Observable<Void> { get }
}

final class SplashViewModel: SplashViewModelType {
  typealias Depedency = RemoteConfigInjectable & SecuredDataStoreInjectable

  init(dependency: Depedency) {
    self.remoteConfig = dependency.remoteConfig
    self.secureDataStore = dependency.securedDataStore
  }

  private let remoteConfig: RemoteConfig
  private let secureDataStore: SecuredDataStore
  private let _onStateChange = BehaviorRelay<SplashViewState>(value: .none)
  private let _onSplashComplete = PublishSubject<Void>()
  var onStateChange: Observable<SplashViewState> { _onStateChange.asObservable() }
  var onSplashCompleted: Observable<Void> { _onSplashComplete.asObservable() }
  func loadRemoteConfig() {
    _onStateChange.accept(.none)
    remoteConfig.fetchAndActivate { [weak self] status, error in
      guard let self = self else { return }
      if error != nil {
        self.handleError(with: error?.localizedDescription)
        return
      }
      switch status {
      case .successFetchedFromRemote:
        if let stringValue = self.remoteConfig.configValue(forKey: "guardianKey").stringValue {
          self.secureDataStore.saveGuardianKey(stringValue)
          self._onStateChange.accept(.none)
          self._onSplashComplete.onNext(())
        } else {
          self._onStateChange.accept(.error(message: "Something went wrong. Please Try Again!!!."))
        }
      default:
        self.handleError(with: error?.localizedDescription)
      }
    }
  }

  final func handleError(with message: String?) {}
}
