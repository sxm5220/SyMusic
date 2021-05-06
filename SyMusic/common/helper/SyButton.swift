//
//  SyButton.swift
//  SyMusic
//
//  Created by sxm on 2020/5/13.
//  Copyright © 2020 wwsq. All rights reserved.
// -- 按钮相关 --

import Foundation
import UIKit

enum TYButtonEdgeInsetsStyle : Int {
    case top // image在上，label在下
    case left // image在左，label在右
    case bottom // image在下，label在上
    case right // image在右，label在左
}

extension UIButton {
    
    func layoutButton(with style: TYButtonEdgeInsetsStyle, imageTitleSpace space: CGFloat) {
        // 1. 得到imageView和titleLabel的宽、高
        let imageWidth: CGFloat? = imageView?.frame.size.width
        let imageHeight: CGFloat? = imageView?.frame.size.height
        
        var labelWidth: CGFloat = 0.0
        var labelHeight: CGFloat = 0.0
        if Float(UIDevice.current.systemVersion) ?? 0.0 >= 8.0 {
            // 由于iOS8中titleLabel的size为0，用下面的这种设置
            labelWidth = titleLabel?.intrinsicContentSize.width ?? 0.0
            labelHeight = titleLabel?.intrinsicContentSize.height ?? 0.0
        } else {
            labelWidth = titleLabel?.frame.size.width ?? 0.0
            labelHeight = titleLabel?.frame.size.height ?? 0.0
        }
        
        // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
        var imageEdgeInsets: UIEdgeInsets = .zero
        var labelEdgeInsets: UIEdgeInsets = .zero
        // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
        switch style {
        case .top:
            //CGFloat top, CGFloat left, CGFloat bottom, CGFloat right
            imageEdgeInsets = UIEdgeInsets.init(top: -labelHeight - space / 2.0, left: 0, bottom: 0, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets.init(top: 0, left: -30, bottom: (imageHeight! * -1) - space / 2.0, right: 0)
        case .left:
            imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -space / 2.0, bottom: 0, right: space / 2.0)
            labelEdgeInsets = UIEdgeInsets.init(top: 0, left: space / 2.0, bottom: 0, right: -space / 2.0)
        case .bottom:
            imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: -labelHeight - space / 2.0, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets.init(top: (-1 * imageHeight!) - space / 2.0, left: (-1 * imageWidth!), bottom: 0, right: 0)
        case .right:
            imageEdgeInsets = UIEdgeInsets.init(top: 0, left: labelWidth + space / 2.0, bottom: 0, right: -labelWidth - space / 2.0)
            labelEdgeInsets = UIEdgeInsets.init(top: 0, left: (-1 * imageWidth!) - space / 2.0, bottom: 0, right: imageWidth! + space / 2.0)
        }
        // 4. 赋值
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
    
    func itemTitleButton(tag: Int, title: String) -> UIButton {
        let itemTitleButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        itemTitleButton.tag = tag
        itemTitleButton.setTitle(title, for: .normal)
        //        itemButton.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        return itemTitleButton
    }
    
    func itemButton(tag: Int, image: UIImage) -> UIButton {
        let itemButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        itemButton.tag = tag
        itemButton.setImage(image, for: .normal)
        //        itemButton.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        return itemButton
    }
}

func buttonWithTitleFrame(frame: CGRect,
                          title: String,
                          titleColor: UIColor,
                          backgroundColor: UIColor,
                          cornerRadius: CGFloat,
                          tag: Int,
                          target: AnyObject,
                          action: Selector) -> SyBadgeButton {
    let button = SyBadgeButton()
    button.frame = frame
    button.setTitle(title, for: .normal)
    button.setTitleColor(titleColor, for: .normal)
    button.backgroundColor = backgroundColor
    if cornerRadius > 0 {
        button.layer.cornerRadius = cornerRadius
    }
    button.tag = tag
    button.addTarget(target, action: action, for: .touchUpInside)
    return button
}

func buttonWithImageFrame(frame: CGRect,
                          imageName: UIImage,
                          tag: Int,
                          target: AnyObject,
                          action: Selector) -> SyBadgeButton {
    let button = SyBadgeButton()
    button.frame = frame
    button.backgroundColor = UIColor.clear
    button.setBackgroundImage(imageName, for: .normal)
    button.tag = tag
    button.addTarget(target, action: action, for: .touchUpInside)
    return button
}

// 按钮右侧数字提示
class SyBadgeButton: UIButton {
    
    let hValue: Double = 3.5
    var badgeLabel = UILabel()
    
    public var badgeValue: String? {
        didSet {
            addBadgeToButon(badge: badgeValue)
        }
    }

    public var badgeBackgroundColor = UIColor.red {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    public var badgeTextColor = UIColor.white {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }
    
    public var badgeFont = UIFont.systemFont(ofSize: 9.0) {
        didSet {
            badgeLabel.font = badgeFont
        }
    }
    
    public var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            addBadgeToButon(badge: badgeValue)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addBadgeToButon(badge: nil)
    }
    
    func addBadgeToButon(badge: String?) {
        badgeLabel.text = badge
        badgeLabel.textColor = badge?.trimmingCharactersCount ?? 0 > 0 ? badgeTextColor : UIColor.clear
        badgeLabel.backgroundColor = badge?.trimmingCharactersCount ?? 0 > 0 ? badgeBackgroundColor : UIColor.clear
        badgeLabel.font = badgeFont
        badgeLabel.sizeToFit()
        badgeLabel.textAlignment = .center
        let badgeSize = badgeLabel.frame.size
        
        let height = max(15, Double(badgeSize.height))
        let width = max(height, Double(badgeSize.width) + 5.0)
        
        var vertical: Double?, horizontal: Double?
        if let badgeInset = self.badgeEdgeInsets {
            vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
            horizontal = Double(badgeInset.left) - Double(badgeInset.right)
            
            let x = (Double(bounds.size.width) - 10 + horizontal!)
            let y = -(Double(badgeSize.height) / 2) - 10 + vertical!
            badgeLabel.frame = CGRect(x: x, y: y, width: width - hValue, height: height - hValue)
        } else {
            let x = self.frame.width - CGFloat((width / 2.0))
            let y = CGFloat(-(height / 2.0)) + 2
            badgeLabel.frame = CGRect(x: x, y: y, width: CGFloat(width - hValue), height: CGFloat(height - hValue))
        }
        
        badgeLabel.layer.cornerRadius = badgeLabel.frame.height/2
        badgeLabel.layer.masksToBounds = true
        addSubview(badgeLabel)
        badgeLabel.isHidden = badge != nil ? false : true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addBadgeToButon(badge: nil)
        fatalError("init(coder:) has not been implemented")
    }
}
