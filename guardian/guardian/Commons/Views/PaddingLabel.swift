//
//  PaddingLabel.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import UIKit

@IBDesignable class PaddingLabel: UILabel {
  @IBInspectable var topInset: CGFloat = 5.0
  @IBInspectable var bottomInset: CGFloat = 5.0
  @IBInspectable var leftInset: CGFloat = 10.0
  @IBInspectable var rightInset: CGFloat = 10.0
  @IBInspectable var bottomBorder: Bool = false
  @IBInspectable var allBorder: Bool = false

  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    super.drawText(in: rect.inset(by: insets))
  }

  override func draw(_ rect: CGRect) {
    if bottomBorder {
      let bottomBorder = CALayer()
      bottomBorder.borderWidth = 1.0
      bottomBorder.borderColor = UIColor.darkGray.cgColor
      bottomBorder.frame = CGRect(x: -1, y: rect.size.height - 1, width: rect.size.width, height: 1)
      layer.addSublayer(bottomBorder)
    } else if allBorder {
      layer.borderColor = UIColor.white.cgColor
      layer.borderWidth = 1.0
    }
    super.draw(rect)
  }

  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(width: size.width + leftInset + rightInset,
                  height: size.height + topInset + bottomInset)
  }
}
