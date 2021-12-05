//
//  NewsApi.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import Moya

enum NewsAPI {
  case getNews(query: String)
}

extension NewsAPI: TargetType {
  var baseURL: URL {
    URL(string: "https://content.guardianapis.com")!
  }

  var path: String {
    switch self {
    case .getNews:
      return "/search"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getNews:
      return .get
    }
  }

  var sampleData: Data {
    "{}".data(using: String.Encoding.utf8)!
  }

  var task: Task {
    switch self {
    case .getNews(let query):
      let fields = "body,thumbnail"
      let orderBy = "newest"
      let orderDate = "published"
      let apiKey = "88bb0b71-0f3a-46d2-9b30-29ea0b8f8177"
      return .requestParameters(parameters:
        [
          "q": query,
          "show-fields": fields,
          "order-by": orderBy,
          "order-date": orderDate,
          "api-key": apiKey
        ],
        encoding: URLEncoding(destination: .queryString))
    }
  }

  var headers: [String: String]? {
    [:]
  }
}
