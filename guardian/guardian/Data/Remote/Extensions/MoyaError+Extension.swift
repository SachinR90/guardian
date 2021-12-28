//
//  MoyaError+Extension.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Alamofire
import Foundation
import Moya

extension MoyaError {
  func isNetworkConnectionError() -> Bool {
    switch self {
      case let .underlying(nsError as AFError, _):
        if let error = nsError.underlyingError as? URLError,
           error.code == .notConnectedToInternet || error.code == .timedOut
        {
          return true
        }
      default:
        break
    }

    return false
  }

  func codeIfStatusError() -> Int? {
    var retCode: Int?
    if case let .underlying(nsError as AFError, _) = self,
       case let AFError.responseValidationFailed(reason) = nsError,
       case let AFError.ResponseValidationFailureReason.unacceptableStatusCode(code) = reason
    {
      retCode = code
    }

    return retCode
  }

  func isRateLimitingError() -> Bool {
    var retValue = false
    if case let .underlying(aError as ApiError, _) = self,
       case ApiError.requestRateLimited = aError
    {
      retValue = true
    }

    return retValue
  }

  func toAppError() -> Error {
    if let code = codeIfStatusError() {
      return appError(for: code)
    } else if isNetworkConnectionError() {
      return ApiError.notConnectedToInternet
    } else if isRateLimitingError() {
      return ApiError.requestRateLimited
    }

    return ApiError.somethingHappend(error: self)
  }

  func appError(for statusCode: Int) -> ApiError {
    switch statusCode {
      case 422:
        guard let errorMessage = ApiError.errorMessage_422(data: response?.data) else {
          return ApiError.statusCode(code: statusCode)
        }
        return ApiError.error422(message: errorMessage)
      case 401: return ApiError.authenticationError(code: 401)
      default:
        return ApiError.statusCode(code: statusCode)
    }
  }
}
