//
//  SyWaterWaveView.swift
//  SyMusic
//
//  Created by sxm on 2022/3/15.
//  Copyright © 2022 wwsq. All rights reserved.
//  雷达搜索

import UIKit

class SyWaterWaveView: UIView {
    
    public let itemsSize = CGSize.init(width: 44, height: 44)
    public var itemsArray: NSMutableArray = NSMutableArray()
    public var animationLayer: CALayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.resume),name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func resume() {
        self.animationLayer.removeFromSuperlayer()
        self.setNeedsDisplay()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func itemFrameIntersectsInOtherItem(frame: CGRect) -> Bool {
        for item in self.itemsArray {
            if ((item as? UIView)?.frame.intersects(frame)) != nil {
                if (((item as? UIView)?.frame.intersects(frame))!) {
                    return true
                }
            }
        }
        return false
    }
    
    public func generateCenterPointInRadar() -> CGPoint{
        let angle = Double(arc4random()).truncatingRemainder(dividingBy: 360)
        let radius = Double(arc4random()).truncatingRemainder(dividingBy: (Double)((self.bounds.size.width - self.itemsSize.width)/2))
        let x = cos(angle) * radius
        let y = sin(angle) * radius
        return CGPoint.init(x: CGFloat(x) + self.bounds.size.width / 2, y: CGFloat(y) + self.bounds.size.height / 2)
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.clear.setFill()
        UIRectFill(rect)
        let pulsingCount = 8 //值越大波圈越密
        let animationDuration: Double = 13 //值越大波动越慢
        
        let animationLayer = CALayer()
        for i in 0 ..< pulsingCount {
            let pulsingLayer = CALayer()
            pulsingLayer.frame = CGRect.init(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
            pulsingLayer.backgroundColor = UIColor.init(white: 0.667, alpha: 0.2).cgColor
            pulsingLayer.borderColor = UIColor.init(white: 0.5, alpha: 0.2).cgColor
            pulsingLayer.borderWidth = 0.5
            pulsingLayer.cornerRadius = rect.size.height / 2
            
            let defaultCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            
            let animationGroup = CAAnimationGroup()
            animationGroup.fillMode = CAMediaTimingFillMode.backwards
            animationGroup.beginTime = CACurrentMediaTime() + Double(i) * animationDuration / Double(pulsingCount)
            animationGroup.duration = animationDuration
            animationGroup.repeatCount = HUGE
            animationGroup.timingFunction = defaultCurve
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = Double(0)
            scaleAnimation.toValue = Double(1.5)
            
            let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnimation.values = [1,0.7,0]
            opacityAnimation.keyTimes = [0,0.5,1]
            
            animationGroup.animations = [scaleAnimation,opacityAnimation]
            
            pulsingLayer.add(animationGroup, forKey: "pulsing")
            animationLayer.addSublayer(pulsingLayer)
        }
        self.layer.addSublayer(animationLayer)
        self.animationLayer = animationLayer
    }
    //触摸任意位置清除
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     let touch = ((touches as NSSet).anyObject() as AnyObject)
     if touch.tapCount == 1 {
     if self.superview != nil {
     UIView.animate(withDuration: 1, animations: {
     self.superview?.alpha = 0
     }, completion: { (isCompletion) in
     self.superview?.removeFromSuperview()
     })
     }
     }
     }*/
}
