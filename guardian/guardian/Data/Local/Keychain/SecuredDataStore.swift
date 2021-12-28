//
//  KeyChainStore.swift
//  guardian
//
//  Created by Sachin Rao on 18/12/21.
//

import Foundation
import SwiftKeychainWrapper

protocol SecuredDataStore {
  // MARK: for guardian api keys

  func saveGuardianKey(_ key: String)
  func getGuardianKey() -> String?
  func hasGuardianKey() -> Bool
}

struct KeyChainDataStore: SecuredDataStore {
  init(with kcwrapper: KeychainWrapper) {
    self.keyChaingWrapper = kcwrapper
  }

  private let keyChaingWrapper: KeychainWrapper

  func getGuardianKey() -> String? {
    keyChaingWrapper.string(forKey: "guardianKey")
  }

  func saveGuardianKey(_ key: String) {
    keyChaingWrapper.set(key, forKey: "guardianKey")
  }

  func hasGuardianKey() -> Bool {
    keyChaingWrapper.hasValue(forKey: "guardianKey")
  }
}
