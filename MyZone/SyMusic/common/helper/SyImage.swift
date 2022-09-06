//
//  SyImage.swift
//  SyMusic
//
//  Created by sxm on 2020/5/25.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit
import Accelerate

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

extension UIImage {
    
    static func getNewImage(_ sourceImage: UIImage?, str: String?) -> UIImage? {
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
    
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.set()
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        self.init(data: image.pngData()!)!
    }
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            SyPrint("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL = URL(string: gifUrl)
            else {
                SyPrint("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            SyPrint("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        //        guard let bundleURL = Bundle.main
        //            .url(forResource: name, withExtension: "gif") else {
        //                print("SwiftGif: This image named \"\(name)\" does not exist")
        //                return nil
        //        }
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: nil) else {
                SyPrint("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            SyPrint("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        
        return animation
    }
    
    //截取scrollerView
    func captureScrollView(_ scrollView: UIScrollView?) -> UIImage? {
        var image: UIImage? = nil
        UIGraphicsBeginImageContext((scrollView?.contentSize)!)
        do {
            let savedContentOffset: CGPoint? = scrollView?.contentOffset
            let savedFrame: CGRect? = scrollView?.frame
            scrollView?.contentOffset = CGPoint.zero
            scrollView?.frame = CGRect(x: 0, y: 0, width: scrollView?.contentSize.width ?? 0.0, height: scrollView?.contentSize.height ?? 0.0)
            
            if let context = UIGraphicsGetCurrentContext() {
                scrollView?.layer.render(in: context)
            }
            image = UIGraphicsGetImageFromCurrentImageContext()
            
            scrollView?.contentOffset = savedContentOffset ?? CGPoint.zero
            scrollView?.frame = savedFrame ?? CGRect.zero
        }
        UIGraphicsEndImageContext()
        if image != nil {
            return image
        }
        return nil
    }
    
    //根据文字生成图片
    func imageFromText(arrContent: NSArray, fontSize: CGFloat) -> UIImage {
        let font = UIFont.systemFont(ofSize: fontSize)
        let arrHeight = NSMutableArray.init(capacity: arrContent.count)
        
        var fHeight: CGFloat = 0
        for sContent in arrContent {
            let stringSize = (sContent as? NSString)?.boundingRect(with: CGSize.init(width: screenWidth, height: 10000), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
            arrHeight.add(stringSize?.height as Any)
            fHeight += (stringSize?.height)!
        }
        let newSize = CGSize.init(width: screenWidth + 20, height: fHeight + 50)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx!.setCharacterSpacing(10)
        ctx?.setTextDrawingMode(.fillStroke)
        ctx?.setFillColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1)
        ctx?.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        var nIndex: Int = 0
        var fPosY: CGFloat = 20
        for sContent in arrContent {
            let numHeight: CGFloat = arrHeight.object(at: nIndex) as! CGFloat
            (sContent as? NSString)?.draw(in: CGRect.init(x: 10, y: fPosY, width: screenWidth, height: numHeight), withAttributes: [NSAttributedString.Key.font: font])
            fPosY += numHeight
            nIndex += 1
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        return image!
    }

    /* 限定图片的大小 */
    func resize(width:CGFloat, height:CGFloat) -> UIImage {
        let myImageSize = CGSize.init(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(myImageSize, false, 0.0)
        let myImageRect = CGRect.init(x: 0, y: 0, width: myImageSize.width, height: myImageSize.height)
        self.draw(in: myImageRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /*生成纯色图片*/
    class func imageColored(color: UIColor) -> UIImage! {
        let rect = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
        UIGraphicsBeginImageContextWithOptions(rect.size, color.cgColor.alpha == 1, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /*  压缩图片，最大为1M  */
    func compressImage(maxImageSize: CGFloat, maxSizeWithKB: CGFloat) -> NSData {
        var maxImgWithKB = maxSizeWithKB
        var maxImgSize = maxImageSize
        
        if maxImgWithKB <= 0 {
            maxImgWithKB = 1024
        }
        
        if maxImgSize <= 0 {
            maxImgSize = 1024
        }
        
        // 调整分辨率
        var newSize = CGSize.init(width: self.size.width, height: self.size.height)
        let tempHeight = newSize.height / maxImgSize
        let tempWidth = newSize.width / maxImgSize
        
        if (tempWidth > 1.0 && tempWidth > tempHeight) {
            newSize = CGSize.init(width: self.size.width / tempWidth, height: self.size.height / tempHeight)
        } else if (tempHeight > 1.0 && tempWidth < tempHeight) {
            newSize = CGSize.init(width: self.size.width / tempHeight, height: self.size.width / tempHeight)
        }
        
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 调整大小
        var imageData = newImage!.jpegData(compressionQuality: 1.0)
        var sizeOriginKB = CGFloat(imageData!.count) / 1024
        
        var resizeRate: CGFloat = 0.9
        while (sizeOriginKB > maxImgWithKB && resizeRate > 1.0) {
            imageData = newImage!.jpegData(compressionQuality: resizeRate)
            sizeOriginKB = CGFloat(imageData!.count) / 1024
            resizeRate -= 0.1
        }
        
        return imageData! as NSData
    }
    
    /*图片着色*/
    func tint(color: UIColor, blendMode: CGBlendMode) -> UIImage {
        let drawRect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: blendMode, alpha: 1.0)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return tintedImage
    }
    
    func withOverlayColor(overlayColor: UIColor) -> UIImage {
        let image = self
        let rect: CGRect = CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.clip(to: rect, mask: image.cgImage!)
        context?.setFillColor(overlayColor.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImage.init(cgImage: (img?.cgImage)!, scale: 1.0, orientation: .downMirrored)
    }
    
    // MARK:- 图片模糊效果处理
    /// 图片模糊效果处理
    /// - parameter image: 需要处理的图片
    /// - parameter level: 模糊程度（0~1）
    func blurry(_ image: UIImage, level: CGFloat) -> UIImage {
        
        // 处理模糊程度, 防止超出
        var levelValue: CGFloat = level
        if level < 0 {
            levelValue = 0.1
        } else if level > 1.0 {
            levelValue = 1.0
        }
        
        // boxSize 必须大于 0
        var boxSize = Int(levelValue * 100)
        boxSize -= (boxSize % 2) + 1
        
        let _cgImage = image.cgImage
        
        // 图像缓存: 输入缓存、输出缓存
        var inBuffer = vImage_Buffer()
        var outBuffer = vImage_Buffer()
        var error = vImage_Error()
        
        
        let inProvider = _cgImage?.dataProvider
        let inBitmapData = inProvider?.data
        
        inBuffer.width = vImagePixelCount((_cgImage?.width)!)
        inBuffer.height = vImagePixelCount((_cgImage?.height)!)
        inBuffer.rowBytes = (_cgImage?.bytesPerRow)!
        inBuffer.data = UnsafeMutableRawPointer(mutating: CFDataGetBytePtr(inBitmapData!))
        
        // 像素缓存
        let pixelBuffer = malloc((_cgImage?.bytesPerRow)! * (_cgImage?.height)!)
        outBuffer.data = pixelBuffer
        outBuffer.width = vImagePixelCount((_cgImage?.width)!)
        outBuffer.height = vImagePixelCount((_cgImage?.height)!)
        outBuffer.rowBytes = (_cgImage?.bytesPerRow)!
        
        // 中间缓存区, 抗锯齿
        let pixelBuffer2 = malloc((_cgImage?.bytesPerRow)! * (_cgImage?.height)!)
        var outBuffer2 = vImage_Buffer()
        outBuffer2.data = pixelBuffer2
        outBuffer2.width = vImagePixelCount((_cgImage?.width)!)
        outBuffer2.height = vImagePixelCount((_cgImage?.height)!)
        outBuffer2.rowBytes = (_cgImage?.bytesPerRow)!
        
        
        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, vImage_Flags(kvImageEdgeExtend))
        error = vImageBoxConvolve_ARGB8888(&outBuffer2, &outBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, vImage_Flags(kvImageEdgeExtend))
        
        if error != kvImageNoError {
            debugPrint(error)
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext(data: outBuffer.data, width: Int(outBuffer.width), height: Int(outBuffer.height), bitsPerComponent: 8, bytesPerRow: outBuffer.rowBytes, space: colorSpace, bitmapInfo: (_cgImage?.bitmapInfo.rawValue)!)
        
        let finalCGImage = ctx!.makeImage()
        let finalImage = UIImage(cgImage: finalCGImage!)
        
        free(pixelBuffer!)
        free(pixelBuffer2!)
        
        return finalImage
    }
}

