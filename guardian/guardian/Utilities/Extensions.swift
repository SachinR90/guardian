//
//  Extensions.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

// MARK: - Date

extension DateFormatter {
  func milliSecondsSince1970(from dateString: String) -> Double {
    let dt = date(from: dateString)
    var value: Double = 0.0
    if let d = dt {
      // NOTE: `d` is Date in UTC
      value = d.timeIntervalSince1970 * 1000
    }
    return value
  }
}

extension Date {
  static func - (lhs: Date, rhs: Date) -> TimeInterval {
    lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
  }

  static func seconds(from referenceDate: Date) -> TimeInterval {
    Date().timeIntervalSince(referenceDate)
  }
}

// MARK: - NSNumber

extension NSNumber {
  var isBool: Bool { CFBooleanGetTypeID() == CFGetTypeID(self) }
}

// MARK: - Error

extension Error {
  var underlyingError: Error? {
    nil
  }
}

// MARK: - String

extension String {
  func firstNWords(n: Int, separator: String = " ") -> String {
    let array = components(separatedBy: separator)
    if n >= array.count || n <= 0 {
      return self
    } else {
      return array[..<n].joined(separator: separator)
    }
  }

  func json() throws -> [String: Any]? {
    let data = self.data(using: .utf8)!
    return try JSONSerialization
      .jsonObject(with: data, options: .allowFragments)
      as? [String: Any]
  }

  func camelCaseByRemoving(separator: String) -> String {
    let array = lowercased().components(separatedBy: separator)
    return array.joined(separator: " ").capitalized
  }

  func capitalizingFirstLetter() -> String {
    prefix(1).uppercased() + lowercased().dropFirst()
  }

  var isBlank: Bool {
    allSatisfy { $0.isWhitespace }
  }

  func trimmed() -> String {
    trimmingCharacters(in: .whitespacesAndNewlines)
  }

  func trimmedNonEmpty() -> String? {
    let trim = trimmed()
    return trim.isEmpty ? nil : trim
  }

  func stripOutHtml() -> String {
    replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
  }

  func htmlAttributedString(size: CGFloat) -> NSAttributedString? {
    let htmlTemplate = """
    <!doctype html>
    <html>
      <head>
        <style>
          body {
            font-family: -apple-system;
            font-size: \(size)px;
          }
        </style>
      </head>
      <body>
        \(self)
      </body>
    </html>
    """

    guard let data = htmlTemplate.data(using: .utf8) else {
      return nil
    }

    guard let attributedString = try? NSAttributedString(
      data: data,
      options: [.documentType: NSAttributedString.DocumentType.html],
      documentAttributes: nil
    ) else {
      return nil
    }

    return attributedString
  }
}

// MARK: - Data

extension Data {
  func json() -> [String: Any]? {
    try? JSONSerialization
      .jsonObject(with: self, options: .allowFragments)
      as? [String: Any]
  }

  func string() -> String {
    String(decoding: self, as: UTF8.self)
  }
}

// MARK: - Dictionary

extension Dictionary {
  init(keys: [Key], values: [Value]) {
    self.init()

    for (key, value) in zip(keys, values) {
      self[key] = value
    }
  }
}

extension Dictionary where Value: Equatable {
  func keyForValue(_ val: Value) -> Key? {
    first(where: { $1 == val })?.key
  }
}

// MARK: - Array

extension Array {
  func grouped<T: Hashable>(by keyForValue: (Element) -> T) -> [T: [Element]] {
    Dictionary(grouping: self, by: keyForValue)
  }

  public subscript(safeIndex index: Int) -> Element? {
    guard index >= 0, index < endIndex else {
      return nil
    }

    return self[index]
  }

  func chunked(into size: Int) -> [[Element]] {
    stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}

extension Array where Element: Hashable {
  func removingDuplicates() -> [Element] {
    var addedDict = [Element: Bool]()

    return filter {
      addedDict.updateValue(true, forKey: $0) == nil
    }
  }
}

public extension Array where Element: Equatable {
  mutating func removeObject(_ item: Element) {
    if let index = firstIndex(of: item) {
      remove(at: index)
    }
  }
}

// MARK: - Optional

extension Optional where Wrapped == String {
  var isNonNilNonEmpty: Bool {
    guard let self = self else { return false }
    return !self.isEmpty
  }

  var nonNilNonEmptyString: String? {
    isNonNilNonEmpty ? self : nil
  }

  var isBlank: Bool {
    self?.isBlank ?? true
  }
}

// MARK: - HTTPURLResponse

extension HTTPURLResponse {
  func find(header: String) -> String? {
    let keyValues = allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }

    if let headerValue = keyValues.filter({ $0.0 == header.lowercased() }).first {
      return headerValue.1
    }
    return nil
  }
}
