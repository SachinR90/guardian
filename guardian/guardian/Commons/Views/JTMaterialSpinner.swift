//
//  JTMaterialSpinner.swift
//  guardian
//
//  Created by Sachin Rao on 15/12/21.
//

import Foundation
import UIKit

open class JTMaterialSpinner: UIView {
  public let circleLayer = CAShapeLayer()
  open private(set) var isAnimating = false
  open var animationDuration: TimeInterval = 2.0
    
  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }
    
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }
    
  open func commonInit() {
    self.layer.addSublayer(self.circleLayer)
        
    self.circleLayer.fillColor = nil
    self.circleLayer.lineWidth = 1.5
        
    self.circleLayer.strokeColor = UIColor.orange.cgColor
    self.circleLayer.strokeStart = 0
    self.circleLayer.strokeEnd = 0

    #if swift(>=4.2)
      self.circleLayer.lineCap = CAShapeLayerLineCap.round
    #else
      self.circleLayer.lineCap = kCALineCapRound
    #endif
  }
    
  override open func layoutSubviews() {
    super.layoutSubviews()
        
    if self.circleLayer.frame != self.bounds {
      self.updateCircleLayer()
    }
  }
    
  open func updateCircleLayer() {
    let center = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
    let radius = (self.bounds.height - self.circleLayer.lineWidth) / 2.0
        
    let startAngle: CGFloat = 0.0
    let endAngle: CGFloat = 2.0 * CGFloat.pi
        
    let path = UIBezierPath(arcCenter: center,
                            radius: radius,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: true)
        
    self.circleLayer.path = path.cgPath
    self.circleLayer.frame = self.bounds
  }
    
  open func forceBeginRefreshing() {
    self.isAnimating = false
    self.beginRefreshing()
  }
    
  open func beginRefreshing() {
    if self.isAnimating {
      return
    }
        
    self.isAnimating = true
        
    let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
    rotateAnimation.values = [
      0.0,
      Float.pi,
      2.0 * Float.pi
    ]
        
    let headAnimation = CABasicAnimation(keyPath: "strokeStart")
    headAnimation.duration = (self.animationDuration / 2.0)
    headAnimation.fromValue = 0
    headAnimation.toValue = 0.25
        
    let tailAnimation = CABasicAnimation(keyPath: "strokeEnd")
    tailAnimation.duration = (self.animationDuration / 2.0)
    tailAnimation.fromValue = 0
    tailAnimation.toValue = 1
        
    let endHeadAnimation = CABasicAnimation(keyPath: "strokeStart")
    endHeadAnimation.beginTime = (self.animationDuration / 2.0)
    endHeadAnimation.duration = (self.animationDuration / 2.0)
    endHeadAnimation.fromValue = 0.25
    endHeadAnimation.toValue = 1
        
    let endTailAnimation = CABasicAnimation(keyPath: "strokeEnd")
    endTailAnimation.beginTime = (self.animationDuration / 2.0)
    endTailAnimation.duration = (self.animationDuration / 2.0)
    endTailAnimation.fromValue = 1
    endTailAnimation.toValue = 1
        
    let animations = CAAnimationGroup()
    animations.duration = self.animationDuration
    animations.animations = [
      rotateAnimation,
      headAnimation,
      tailAnimation,
      endHeadAnimation,
      endTailAnimation
    ]
    animations.repeatCount = Float.infinity
    animations.isRemovedOnCompletion = false
        
    self.circleLayer.add(animations, forKey: "animations")
  }
    
  open func endRefreshing() {
    self.isAnimating = false
    self.circleLayer.removeAnimation(forKey: "animations")
  }
}
