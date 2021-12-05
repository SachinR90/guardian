//
//  ApiError.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation

public enum ApiError: Error {
  case notConnectedToInternet
  case error422(message: String)
  case authenticationError(code: Int)
  case statusCode(code: Int)
  case requestRateLimited
  case somethingHappend(error: Error?)
}

extension ApiError {
  var underlyingError: Error? {
    switch self {
      case let .somethingHappend(error):
        return error?.underlyingError
      default:
        return nil
    }
  }
}

extension ApiError: LocalizedError {
  public var errorDescription: String? {
    switch self {
      case .notConnectedToInternet:
        return "We can not connect to the server!"
      case let .error422(message):
        return message
      default:
        return "Something went wrong. Please try again"
    }
  }
}

extension ApiError {
  static func errorMessage_422(data: Data?) -> String? {
    guard let data = data else { return nil }
    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    return json?["message"] as? String
  }

  static func somethingHappenedErrorMessage(internalError: Error?) -> String {
    somethingHappend(error: internalError).message()
  }
}

extension ApiError {
  func message() -> String {
    let finalError: Error = ApiError.somethingHappend(error: self)
    return finalError.localizedDescription
  }
}
