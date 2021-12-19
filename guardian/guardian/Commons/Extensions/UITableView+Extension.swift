//
//  UITableView+Extension.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

protocol ReusableCell: UIView {
  static var defaultReuseIdentifier: String { get }
}

extension ReusableCell {
  static var defaultReuseIdentifier: String {
    String(describing: self)
  }
}

protocol NibLoadableView: UIView {
  static var nibName: String { get }
}

extension NibLoadableView {
  static var nibName: String {
    String(describing: self)
  }
}

extension UICollectionView {
  func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableCell {
    register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
  }

  func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableCell, T: NibLoadableView {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.nibName, bundle: bundle)

    register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
  }

  func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath, _: T.Type) -> T where T: ReusableCell {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
    }

    return cell
  }

  func registerSectionHeader<T: UICollectionReusableView>(_: T.Type) where T: ReusableCell, T: NibLoadableView {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.nibName, bundle: bundle)

    register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.defaultReuseIdentifier)
  }
}

extension UITableView {
  func register<T: UITableViewCell>(_: T.Type) where T: ReusableCell {
    register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
  }

  func register<T: UITableViewCell>(_: T.Type) where T: ReusableCell, T: NibLoadableView {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.nibName, bundle: bundle)

    register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
  }

  func registerSectionHeaderFooter<T: UITableViewHeaderFooterView>(_: T.Type) where T: ReusableCell, T: NibLoadableView {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.nibName, bundle: bundle)

    register(nib, forHeaderFooterViewReuseIdentifier: T.defaultReuseIdentifier)
  }

  func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, _: T.Type) -> T where T: ReusableCell {
    guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
    }
    return cell
  }

  func reload() {
    let offset = contentOffset
    reloadData()
    layoutIfNeeded()
    setContentOffset(offset, animated: false)
  }
}
