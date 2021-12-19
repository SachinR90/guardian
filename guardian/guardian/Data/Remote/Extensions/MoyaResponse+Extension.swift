//
//  MoyaResponse+Extension.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import Moya

extension Moya.Response {
  func mapValue<D: Decodable>(completion: (Result<D, Error>) -> Void) {
    do {
      let value = try map(D.self)
      completion(.success(value))
    } catch {
      completion(.failure(ApiError.somethingHappend(error: error)))
    }
  }

  func mapValue<D: Decodable>(_: D.Type) throws -> D {
    do {
      return try map(D.self)
    } catch {
      throw ApiError.somethingHappend(error: error)
    }
  }
}
