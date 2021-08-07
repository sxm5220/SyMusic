//
//  SyColor.swift
//  SyMusic
//
//  Created by sxm on 2020/5/10.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import UIKit

func rgbWithValue(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
}

func rgbWithHex(rgbValue: Int) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: 1.0)
}

func rgbAWithHex(rgbValue: Int, alpha: CGFloat) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: alpha)
}

func rgbWithHexBm(rgbValue: Int) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue >> 16) & 0xFF))/255.0, green: ((CGFloat)((rgbValue >> 8) & 0xFF))/255.0, blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: 1.0)
}
