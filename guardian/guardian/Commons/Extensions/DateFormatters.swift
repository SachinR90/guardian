//
//  DateFormatters.swift
//  guardian
//
//  Created by Sachin Rao on 17/12/21.
//

import Foundation
class DateFormatters {
  static let DD_MMM_YYYY_HH_MM_A = "dd-MMM-yyyy hh:mm a"
  static let instance = DateFormatters()
  private init() {}
  private let dateFormatter = DateFormatter()
  private let isoFormatter = ISO8601DateFormatter()

  func getIsoFormatter() -> ISO8601DateFormatter {
    isoFormatter
  }

  func getFormatter(for format: String) -> DateFormatter {
    dateFormatter.dateFormat = format
    return dateFormatter
  }
}
