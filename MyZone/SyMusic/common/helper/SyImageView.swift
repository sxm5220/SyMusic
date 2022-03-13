//
//  SyImageView.swift
//  SyMusic
//
//  Created by sxm on 2020/5/14.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit

func sfImage(name: String , _ pointSize : CGFloat? = nil, _ symbolWeight: UIImage.SymbolWeight? = nil, _ color: UIColor? = nil, _ renderingMode: UIImage.RenderingMode? = nil) -> UIImage {
    // 1.可以配置 weight、scale、textStyle等
    let config = UIImage.SymbolConfiguration(pointSize: pointSize ?? 30, weight: symbolWeight ?? .semibold)
    // 2.初始化`UIImage`，当然也可以不传 Configuration
    let img =  UIImage(systemName: name, withConfiguration: config)
    // 3.修改颜色 和 mode
    let sfImg = img?.withTintColor(color ?? .white, renderingMode: renderingMode ?? .alwaysOriginal)
    guard let icon = sfImg else { return UIImage() }
    return icon
}

extension UIImageView {
    //高性能设置圆角
    func roundCorner(imageView: UIImageView) -> CAShapeLayer {
        let maskPath = UIBezierPath.init(roundedRect: imageView.bounds, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: imageView.bounds.size)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = imageView.bounds
        maskLayer.path = maskPath.cgPath
        return maskLayer
    }
}
