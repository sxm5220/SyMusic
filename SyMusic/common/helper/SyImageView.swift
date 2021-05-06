//
//  SyImageView.swift
//  SyMusic
//
//  Created by sxm on 2020/5/14.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit

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
