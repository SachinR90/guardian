//
//  URLRequrest+Extension.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Alamofire
import Foundation

extension URLRequest {
  func urlEncodedInURL(params: [String: Any]) throws -> URLRequest {
    try URLEncoding(destination: .queryString).encode(self, with: params)
  }
}
