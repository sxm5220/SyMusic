//
//  SyView.swift
//  wwsq
//
//  Created by sxm-wwsq on 2017/6/7.
//  Copyright © 2017年 wwsq. All rights reserved.
//

import UIKit

protocol NibLoadable {}

extension NibLoadable {
    static func loadViewFromNib() -> Self {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.last as! Self
    }
}

extension UIView {
    
    public var x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    public var y: CGFloat{
        get {
            return self.frame.origin.y
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    /** 宽 */
    public var width: CGFloat{
        get {
            return self.frame.size.width
        }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    /** 高 */
    public var height: CGFloat{
        get {
            return self.frame.size.height
        }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
   
    /** 上 */
    public var top: CGFloat{
        get {
            return self.frame.origin.y
        }
        
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    /** 下 */
    public var bottom: CGFloat{
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        
        set {
            var frame = self.frame
            frame.origin.y = newValue - self.frame.size.height
            self.frame = frame
        }
    }
    
    /** 左 */
    public var left: CGFloat{
        get {
            return self.frame.origin.x
        }
        
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    /** 右 */
    public var right: CGFloat{
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        
        set {
            var frame = self.frame
            frame.origin.x = newValue - self.frame.size.width
            self.frame = frame
        }
    }
    
    /** 尺寸 */
    public var size: CGSize{
        get {
            return self.frame.size
        }
        
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    /** 竖直中心对齐 */
    public var centerX: CGFloat{
        get {
            return self.center.x
        }
        
        set {
            var center = self.center
            center.x = newValue
            self.center = center
        }
    }
    
    /** 水平中心对齐 */
    public var centerY: CGFloat{
        get {
            return self.center.y
        }
        
        set {
            var center = self.center
            center.y = newValue
            self.center = center
        }
    }
    
    public var origin: CGPoint{
        get{
            return self.frame.origin
        }
        set{
            self.x = newValue.x
            self.y = newValue.y
        }
    }
}

//获得当前View的UIViewController对象
extension UIView {
    
    //view水波效果
    func rippleEffectView(name: String, view: UIView) {
        let animation = CATransition.init()
        //animation.delegate = self
        animation.duration = 3
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.type = convertToCATransitionType(name)
        view.layer.add(animation, forKey: "animation")
    }
    
    //三角形
    func arrowView() -> UIView? {
        let size = CGSize(width: 10, height: 10)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size.width / 2.0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.lineWidth = 1.0
        let arrowLayer = CAShapeLayer()
        arrowLayer.path = path.cgPath
        
        let arrowView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        arrowView.layer.mask = arrowLayer
        arrowView.backgroundColor = UIColor.white
        return arrowView
    }
}


func findFirstResponder(view: UIView) -> UIView {
    
    var firstResponder = UIView.init()
    if view.isFirstResponder {
        return view
    }
    let subViews = view.subviews
    for subView:UIView in subViews {
        firstResponder = findFirstResponder(view: subView)
        return firstResponder
    }
    return firstResponder
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCATransitionType(_ input: String) -> CATransitionType {
	return CATransitionType(rawValue: input)
}
