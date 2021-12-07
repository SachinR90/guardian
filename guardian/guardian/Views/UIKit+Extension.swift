//
//  UIKit+Extension.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import Kingfisher
import UIKit

extension UIColor {
  public convenience init?(hexString: String) {
    let r, g, b, a: CGFloat

    if hexString.hasPrefix("#") {
      let start = hexString.index(hexString.startIndex, offsetBy: 1)
      var hexColor = String(hexString[start...])
      if hexColor.count == 6 {
        hexColor = hexColor + "ff"
      }
      if hexColor.count == 8 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
          r = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
          g = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
          b = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
          a = CGFloat(hexNumber & 0x0000_00FF) / 255

          self.init(red: r, green: g, blue: b, alpha: a)
          return
        }
      }
    }

    return nil
  }

  static func rgba(
    _ red: CGFloat,
    _ green: CGFloat,
    _ blue: CGFloat,
    _ alpha: CGFloat = 1.0
  ) -> UIColor {
    UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
  }
}

@nonobjc extension UIViewController {
  func add(
    containerViewController child: UIViewController,
    onView subView: UIView? = nil,
    layoutMargins: UIEdgeInsets? = nil
  ) {
    addChild(child)

    var parentView: UIView = view
    if let sub_view = subView {
      parentView = sub_view
    }

    parentView.addSubview(child.view)

    if let layout_Margins = layoutMargins {
      child.view.frame = parentView.bounds.inset(by: layout_Margins)
    } else {
      child.view.frame = parentView.bounds
    }
    child.didMove(toParent: self)
  }

  func remove() {
    // Just to be safe, we check that this view controller
    // is actually added to a parent before removing it.
    guard parent != nil else {
      return
    }

    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
  }
}

public extension UIAppearance {
  @discardableResult
  func style(_ styleClosure: (Self) -> Void) -> Self {
    styleClosure(self)
    return self
  }
}

/// Usage
/// view.add(label)
/// view.add(button, label)
extension UIView {
  func add(_ subviews: UIView...) {
    subviews.forEach(addSubview)
  }
}

// UIView Tap gesture
extension UIView {
  func addTapGesture(target: Any?, action: Selector?) {
    let tapGestureRecognizer = UITapGestureRecognizer(target: target, action: action)
    addGestureRecognizer(tapGestureRecognizer)
  }
}

extension UIView {
  func shrink(
    down: Bool,
    duration: TimeInterval = 0.2,
    downScaleX: CGFloat = 0.97,
    downScaleY: CGFloat = 0.97
  ) {
    UIView.animate(withDuration: duration) {
      if down {
        self.transform = CGAffineTransform(scaleX: downScaleX, y: downScaleY)
      } else {
        self.transform = .identity
      }
    }
  }
}

// UIScrollView Paging
extension UIScrollView {
  func scrollTo(horizontalPage: Int? = 0, verticalPage: Int? = 0, animated: Bool? = true) {
    var frame = CGRect.zero
    let bounds = UIScreen.main.bounds
    frame.origin.x = bounds.size.width * CGFloat(horizontalPage ?? 0)
    frame.origin.y = bounds.size.height * CGFloat(verticalPage ?? 0)
    setContentOffset(frame.origin, animated: animated ?? false)
  }

  func scrollToRightPage(animated: Bool? = true) {
    var frame = CGRect.zero
    let bounds = UIScreen.main.bounds
    frame.origin.x = contentOffset.x + bounds.size.width
    if frame.origin.x >= contentSize.width {
      return
    }
    setContentOffset(frame.origin, animated: animated ?? false)
  }

  func scrollToLeftPage(animated: Bool? = true) {
    var frame = CGRect.zero
    let bounds = UIScreen.main.bounds
    frame.origin.x = contentOffset.x - bounds.size.width
    if frame.origin.x < 0 {
      return
    }
    setContentOffset(frame.origin, animated: animated ?? false)
  }

  func currentPage() -> Int {
    let page = Int((contentOffset.x + (0.5 * frame.width)) / frame.width)
    return page
  }
}

// Circular Imageview
class CircularImageView: UIImageView {
  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = frame.size.width / 2
    clipsToBounds = true
  }
}

extension UIButton {
  func animateTitle(
    title: String,
    for state: UIControl.State,
    duration: TimeInterval,
    completion: ((Bool) -> Void)? = nil
  ) {
    UIView.transition(with: self,
                      duration: duration,
                      options: .transitionCrossDissolve, animations: {
                        self.setTitle(title, for: state)
                      }, completion: completion)
  }

  func setImage(
    for urlString: String?,
    imagePlacholder: UIImage? = nil,
    circular: Bool = true,
    progressBlock: DownloadProgressBlock? = nil,
    completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
  ) {
    var imageUrl: URL?

    if let urlString = urlString,
       let percentEncodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    {
      imageUrl = URL(string: percentEncodedString)
    }

    kf.setImage(with: imageUrl,
                for: .normal,
                placeholder: imagePlacholder,
                options: [
                  .scaleFactor(UIScreen.main.scale),
                  .transition(.none),
                ],
                progressBlock: progressBlock,
                completionHandler: { result in
                  if circular {
                    self.layer.cornerRadius = self.frame.width / 2
                  }
                  completionHandler?(result)
                })
  }
}

// https://getswifty.dev/adding-closures-to-buttons-in-swift/
extension UIControl {
  /// Typealias for UIControl closure.
  public typealias UIControlTargetClosure = (UIControl) -> Void

  private class UIControlClosureWrapper: NSObject {
    let closure: UIControlTargetClosure
    init(_ closure: @escaping UIControlTargetClosure) {
      self.closure = closure
    }
  }

  private enum AssociatedKeys {
    static var targetClosure = "targetClosure"
    static var debouncer = "debouncer"
  }

  private var debouncer: DebouncerFirst? {
    get {
      guard let debounce = objc_getAssociatedObject(self, &AssociatedKeys.debouncer) as? DebouncerFirst else { return nil }
      return debounce
    }
    set(newValue) {
      guard let newValue = newValue else { return }
      objc_setAssociatedObject(self, &AssociatedKeys.debouncer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private var targetClosure: UIControlTargetClosure? {
    get {
      guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? UIControlClosureWrapper else { return nil }
      return closureWrapper.closure
    }
    set(newValue) {
      guard let newValue = newValue else { return }
      objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, UIControlClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  @objc func closureAction() {
    guard let targetClosure = targetClosure else { return }

    if let debouncer = debouncer {
      debouncer.onMainQueue().debounce { [weak self] in
        guard let self = self else { return }
        targetClosure(self)
      }
    } else {
      targetClosure(self)
    }
  }

  public func addAction(
    for event: UIControl.Event,
    debounceMillis: Double? = nil,
    closure: @escaping UIControlTargetClosure
  ) {
    targetClosure = closure
    if let debounce = debounceMillis {
      debouncer = DebouncerFirst(milliseconds: debounce)
    }
    addTarget(self, action: #selector(UIControl.closureAction), for: event)
  }
}

public extension UIView {
  @IBInspectable var cornerRadiusRatio: CGFloat {
    get {
      layer.cornerRadius / frame.width
    }

    set {
      let normalizedRatio = max(0.0, min(1.0, newValue))
      layer.cornerRadius = frame.width * normalizedRatio
    }
  }
}

extension UIColor {
  func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    UIGraphicsImageRenderer(size: size).image { rendererContext in
      self.setFill()
      rendererContext.fill(CGRect(origin: .zero, size: size))
    }
  }
}

extension UIImage {
  var rendingOriginal: UIImage? {
    withRenderingMode(.alwaysOriginal)
  }

  var rendingTemplate: UIImage? {
    withRenderingMode(.alwaysTemplate)
  }

  var rendingAUtomatic: UIImage? {
    withRenderingMode(.automatic)
  }
}

extension NSAttributedString {
  convenience init?(optionalString: String?, attributes: [NSAttributedString.Key: Any]?) {
    guard let string = optionalString else { return nil }
    self.init(string: string, attributes: attributes)
  }
}

extension Sequence where Element: NSAttributedString {
  func joinWithSeparator(separator: NSAttributedString) -> NSAttributedString {
    var isFirst = true
    return reduce(NSMutableAttributedString()) {
      r, e in
      if isFirst {
        isFirst = false
      } else {
        r.append(separator)
      }
      r.append(e)
      return r
    }
  }

  func joinWithSeparator(separator: String) -> NSAttributedString {
    joinWithSeparator(separator: NSAttributedString(string: separator))
  }
}

extension UITableView {
  func scroll(to: scrollsTo, animated: Bool) {
    let numberOfSections = self.numberOfSections
    if numberOfSections > 0 {
      let numberOfRows = self.numberOfRows(inSection: 0)
      if numberOfRows > 0 {
        switch to {
          case .top:
            if numberOfRows > 0 {
              let indexPath = IndexPath(row: 0, section: 0)
              scrollToRow(at: indexPath, at: .top, animated: animated)
            }
          case .bottom:
            if numberOfRows > 0 {
              let indexPath = IndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
              scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
      }
    }
  }

  enum scrollsTo {
    case top, bottom
  }
}

// UIViewController

extension UIViewController {
  func topmostPresentedViewController() -> UIViewController {
    if let presented = presentedViewController {
      return presented.topmostPresentedViewController()
    } else {
      return self
    }
  }

  func isVisible() -> Bool {
    isViewLoaded && parent != nil && view.window != nil
  }

  // Can be used to prsent a view controller as bottom sheet modal above iOS 13
  // It falls back to full screen mode below iOS 13
  static var modalPresentationStyleCompat: UIModalPresentationStyle {
    .automatic
  }
}

// UITextField

extension UITextField {
  // Adds left padding to the typing cursor in text field
  var paddingLeft: CGFloat {
    get {
      leftView!.frame.size.width
    }
    set {
      let leftPaddingView = UIView(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: newValue,
                                                 height: frame.size.height))
      leftView = leftPaddingView
      leftViewMode = .always
    }
  }

  // Adds right padding to the typing cursor in text field
  var paddingRight: CGFloat {
    get {
      rightView!.frame.size.width
    }
    set {
      let rightPaddingView = UIView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: newValue,
                                                  height: frame.size.height))
      rightView = rightPaddingView
      rightViewMode = .always
    }
  }
}

extension UINavigationController {
  // Enable Disable the Interactive Pop Gesture
  func enableDisableInteractivePopGesture(enabled: Bool) {
    interactivePopGestureRecognizer?.isEnabled = enabled
  }

  override open var childForStatusBarStyle: UIViewController? {
    self.topViewController
  }

  override open var childForStatusBarHidden: UIViewController? {
    topViewController
  }
}

extension UIApplication {
  // Finds the top view controller
  class func topViewController(base: UIViewController? = UIApplication.window()?.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topViewController(base: nav.visibleViewController)
    }

    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return topViewController(base: selected)
      }
    }

    if let presented = base?.presentedViewController {
      return topViewController(base: presented)
    }
    return base
  }
}

public extension UIApplication {
  // Method to get the height of the status bar
  static func getStatusBarHeight() -> CGFloat {
    let window = UIApplication.window()
    if let statusBarManager = window?.windowScene?.statusBarManager {
      return statusBarManager.isStatusBarHidden ? 0 : statusBarManager.statusBarFrame.height
    }
    return 0
  }

  static func statusBarStyle() -> UIStatusBarStyle {
    let window = UIApplication.window()
    return window?.windowScene?.statusBarManager?.statusBarStyle ?? .default
  }

  static func isStatusBarHidden() -> Bool {
    let window = UIApplication.window()
    return window?.windowScene?.statusBarManager?.isStatusBarHidden ?? false
  }

  static func window() -> UIWindow? {
    UIApplication.shared.windows.filter { $0.isKeyWindow }.first
  }

  static var isPortrait: Bool {
    shared.windows
      .first?
      .windowScene?
      .interfaceOrientation
      .isPortrait ?? true
  }
}

extension CGFloat {
  static func random() -> CGFloat {
    CGFloat(arc4random()) / CGFloat(UInt32.max)
  }
}

extension UIColor {
  static func random() -> UIColor {
    UIColor(red: .random(),
            green: .random(),
            blue: .random(),
            alpha: 1.0)
  }
}

extension UIDevice {
  var modelName: String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return identifier
  }
}

extension UIEdgeInsets {
  static func insets(
    _ top: CGFloat,
    _ left: CGFloat,
    _ bottom: CGFloat,
    _ right: CGFloat
  ) -> UIEdgeInsets {
    UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
  }
}

extension UIButton {
  func underlineText() {
    guard let title = title(for: .normal) else { return }

    let titleString = NSMutableAttributedString(string: title)
    titleString.addAttribute(.underlineStyle,
                             value: NSUnderlineStyle.single.rawValue,
                             range: NSRange(location: 0, length: title.count))
    setAttributedTitle(titleString, for: .normal)
  }
}
