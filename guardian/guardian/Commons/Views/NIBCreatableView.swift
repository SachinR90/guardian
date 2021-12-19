//
//  NIBCreatableView.swift
//  guardian
//
//  Created by Sachin Rao on 15/12/21.
//

import Foundation
import UIKit

class NibCreatableView: UIView {
  @IBOutlet var containerView: UIView!

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  var nibName: String {
    String(describing: type(of: self))
  }

  func commonInit() {
    let name = nibName
    let nib = UINib(nibName: name, bundle: .main)
    nib.instantiate(withOwner: self, options: nil)

    addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    containerView.backgroundColor = .clear
  }
}
