//
//  SyString.swift
//  SyMusic
//
//  Created by sxm on 2020/5/10.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    //获取字符串宽度
    func widthForComment(fontSize: CGFloat, height: CGFloat = 15) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
    
    //获取字符串高度
    func heightForComment(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
    
    
    
    /**
     Get the height with font.
     
     - parameter font:       The font.
     - parameter fixedWidth: The fixed width.
     
     - returns: The height.
     */
    func heightWithFont(font :UIFont = UIFont.systemFont(ofSize: 18), fixedWidth :CGFloat) -> CGFloat {
        
        guard self.trimmingCharactersCount > 0 && fixedWidth > 0 else {
            
            return 0
        }
        
        let size = CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        let text = self as NSString
        let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
        
        return rect.size.height
    }
    
    /*
     *去掉所有空格
     */
    var removeAllSapce: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    
    //字符串个数
    var trimmingCharactersCount: Int {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).count
    }
    
    //字符串竖排显示
    func verticalString() -> String? {
        var str = self
        let count: Int = str.count
        for i in 1..<count {
            str.insert(contentsOf: "\n", at: str.index(str.startIndex, offsetBy: i * 2 - 1))
        }
        return str
    }
    
    var xb_MD5: String {
        if let data = data(using: String.Encoding.utf8) {
            let MD5Calculator = MD5(Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count: data.count)))
            let MD5Data = MD5Calculator.calculate()
            
            let MD5String = NSMutableString()
            for c in MD5Data {
                MD5String.appendFormat("%02x", c)
            }
            return MD5String as String
            
        } else {
            return self
        }
    }
    
    //截取字符串
    func nsRange(from range: Range<String.Index>) -> NSRange? {
        let utf16view = self.utf16
        if let from = range.lowerBound.samePosition(in: utf16view), let to = range.upperBound.samePosition(in: utf16view) {
            return NSMakeRange(utf16view.distance(from: utf16view.startIndex, to: from), utf16view.distance(from: from, to: to))
        }
        return nil
    }
}

//比较字符串大小(eg:"2.7.3" "2.7.4")
func compareVersion(str1: String, str2: String) -> Bool {
    let compareResult = str1.compare(str2, options: .numeric, range: nil, locale: nil)
    return (compareResult == .orderedAscending)
}

//截取字符串（前几位）
func strFrontValue(value: String, count: Int) -> String {
    return String(value[..<value.index(value.startIndex, offsetBy: count)])
}

//截取字符串（后几位）
func strLastValue(value: String, count: Int) -> String {
  return String(value[value.index(value.startIndex, offsetBy: value.count - count)...])
}

//字符串显示不同颜色
func changeColorStyleOfString(allString: String,rangeString: String,frontColor: UIColor,endColor: UIColor) ->NSMutableAttributedString {
    let attriStr:NSMutableAttributedString = NSMutableAttributedString(string: allString)
    let range = NSMakeRange(NSString(string: allString).range(of: rangeString).location, NSString(string: allString).range(of: rangeString).length)
    //前面的颜色 frontColor
    attriStr.addAttribute(NSAttributedString.Key.foregroundColor, value: frontColor, range: NSMakeRange(0, range.location))
    //后面的颜色 endColor
    attriStr.addAttribute(NSAttributedString.Key.foregroundColor, value: endColor, range: range)
    return attriStr
}

//带下划线的字符串
func underlineStyleOfString(string: String) -> NSMutableAttributedString {
    let strings = NSMutableAttributedString.init(string: string)
    let strRange = NSRange.init(location: 0, length: strings.length)
    strings.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: strRange)
    return strings
}

// 根据字体个数自动适配高度
func autoLayoutHeightWithFontSize(font: UIFont, width: CGFloat, contentText: String) -> CGRect {
    let options: NSStringDrawingOptions = .usesLineFragmentOrigin
    let rect = contentText.boundingRect(with: CGSize.init(width: width, height: 0),
                                           options: options,
                                           attributes:[NSAttributedString.Key.font:font],
                                           context: nil)
    return rect
}

//字体上下间距
func attributeStringWithString(_ string: String,lineSpace: CGFloat
    ) -> NSAttributedString{
    let attributedString = NSMutableAttributedString(string: string)
    let paragraphStye = NSMutableParagraphStyle()
    //调整行间距
    paragraphStye.lineSpacing = lineSpace
    let rang = NSMakeRange(0, CFStringGetLength(string as CFString?))
    attributedString.addAttribute(.paragraphStyle, value: paragraphStye, range: rang)
    return attributedString
}
