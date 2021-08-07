//
//  SyImage.swift
//  SyMusic
//
//  Created by sxm on 2020/5/25.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit

extension UIImage {

    class func getNewImage(_ sourceImage: UIImage?, str: String?) -> UIImage? {
        guard let image = sourceImage else { return nil }
        guard let resultStr = str else { return image }
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let textRect = CGRect(x: 0, y: 0, width: image.size.width, height: 28)
        let textDic = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
            NSAttributedString.Key.paragraphStyle: style
        ]
        (resultStr as NSString).draw(in: textRect, withAttributes: textDic)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
}
