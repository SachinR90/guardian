//
//  NetworkType.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import Moya
import RxMoya
import RxSwift

func JSONResponseDataFormatter(_ data: Data) -> String {
  do {
    let dataAsJSON = try JSONSerialization.jsonObject(with: data)
    let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
    return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
  } catch {
    return String(data: data, encoding: .utf8) ?? ""
  }
}

enum NetworkQuality: String {
  case excellent
  case poor
  case veryBad
}

enum ActiveNetworkType: Equatable {
  case unknown
  case wifi(NetworkQuality)
  case mobileData(NetworkQuality)
}

typealias MoyaCompletion = (_ result: Result<Moya.Response, Error>) -> Void

protocol NetworkType {
  associatedtype T: TargetType
  var provider: MoyaProvider<T> { get }

  func processSuccess(response: Moya.Response, for target: TargetType, endpoint: Endpoint)
  func processFailure(error: MoyaError, for target: TargetType, endpoint: Endpoint)
}

extension NetworkType {
  func processSuccess(response _: Moya.Response, for _: TargetType, endpoint _: Endpoint) {}
  func processFailure(error _: MoyaError, for _: TargetType, endpoint _: Endpoint) {}
}

extension NetworkType {
  static var logOption: NetworkLoggerPlugin.Configuration.LogOptions {
    .verbose
  }

  static func alamofireSession() -> Session {
    let configuration = URLSessionConfiguration.default
    configuration.headers = .default
    configuration.timeoutIntervalForRequest = 30.0
    configuration.timeoutIntervalForResource = 60.0
    return Session(configuration: configuration, startRequestsImmediately: false)
  }

  static func defaultPlugins() -> [PluginType] {
    #if DEBUG
      return [
        NetworkLoggerPlugin(configuration: .init(formatter:
          .init(responseData: JSONResponseDataFormatter), logOptions: logOption)),
      ]
    #else
      return []
    #endif
  }
}

extension NetworkType {
  func rxRequest(
    target: T
  ) -> Observable<Response> {
    // Get the endpoint form endPointClosure
    let endpoint = provider.endpoint(target)
    return provider.rx.request(target).asObservable()
      // process success on onNext
      .do(onNext: { response in
        self.processSuccess(response: response, for: target, endpoint: endpoint)
      })
      // process failure on onError, convert it to AppError and rethrow
      .catch { (moyaError: Error) -> Observable<Response> in

        // process failure
        if let error = moyaError as? MoyaError {
          self.processFailure(error: error, for: target, endpoint: endpoint)
        }

        // convert to AppError and terminate the stream
        let appError = self.convertErrorIntoAppError(error: moyaError)
        return Observable.error(appError)
      }
  }

  // Convenient overload to get Observables of custom decodable types
  func rxRequestMapped<D: Decodable>(
    _ type: D.Type,
    target: T
  ) -> Observable<D> {
    rxRequest(target: target).map(type)
  }

  @discardableResult
  func request(
    target: T,
    completion: @escaping MoyaCompletion
  ) -> NetworkCancellable {
    func handleError(_ error: Error) {
      let error = convertErrorIntoAppError(error: error)
      completion(.failure(error))
    }

    // Get the endpoint form endPointClosure
    let endpoint = provider.endpoint(target)
    let cancallable = provider.request(target) { result in
      switch result {
        case let .success(response):
          self.processSuccess(response: response, for: target, endpoint: endpoint)
          completion(.success(response))
        case let .failure(error):
          self.processFailure(error: error, for: target, endpoint: endpoint)
          handleError(error)
      }
    }
    return NetworkCancellable(cancellable: cancallable)
  }
}

extension NetworkType {
  private func convertErrorIntoAppError(error: Error) -> Error {
    if let error = error as? MoyaError {
      return error.toAppError()
    }
    return ApiError.somethingHappend(error: error)
  }
}
