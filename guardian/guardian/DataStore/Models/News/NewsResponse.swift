//
//  NewsResponse.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
struct NewsResponse: Decodable {
  let status: String?
  let userTier: String?
  let total: Int?
  let startIndex: Int?
  let pageSize: Int?
  let currentPage: Int?
  let pages: Int?
  let orderBy: String?
  let results: [News]?

  enum CodingKeys: String, CodingKey {
    case status
    case userTier
    case total
    case startIndex
    case pageSize
    case currentPage
    case pages
    case orderBy
    case results
  }

  enum ResponseKey: String, CodingKey {
    case response
  }

  init(from decoder: Decoder) throws {
    let responseContainer = try decoder.container(keyedBy: ResponseKey.self)
    let container = try responseContainer.nestedContainer(keyedBy: CodingKeys.self,
                                                          forKey: .response)

    self.status = try container.decode(String.self, forKey: .status)
    self.userTier = try container.decode(String.self, forKey: .userTier)
    self.total = try container.decode(Int.self, forKey: .total)
    self.startIndex = try container.decode(Int.self, forKey: .startIndex)
    self.pageSize = try container.decode(Int.self, forKey: .pageSize)
    self.currentPage = try container.decode(Int.self, forKey: .currentPage)
    self.pages = try container.decode(Int.self, forKey: .pages)
    self.orderBy = try container.decode(String.self, forKey: .orderBy)
    self.results = try container.decode([News].self, forKey: .results)
  }
}
