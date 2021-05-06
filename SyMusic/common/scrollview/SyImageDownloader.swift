//
//  SyImageDownloader.swift
//  wwsq
//
//  Created by 宋晓明 on 2018/4/20.
//  Copyright © 2018年 wwsq. All rights reserved.
//

import Foundation
import UIKit

public typealias finishClosure = (_ image: UIImage?) -> ()

open class SyImageDownloader: NSObject {
    fileprivate lazy var imageCache: NSCache<AnyObject, UIImage> = {
        let cache = NSCache<AnyObject, UIImage>()
        cache.countLimit = 10
        return cache
    }()
    
    fileprivate lazy var imageCacheDir: String = {
        var dirString = ""
        if let dir = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                         .userDomainMask,
                                                         true).last {
            dirString = dir + "/SyImageDownloaderCache"
        }
        
        return dirString
    }()
    
    override init() {
        super.init()
        commonInit()
    }
    
    fileprivate func commonInit() {
        let isCacheDirExist = FileManager.default.fileExists(atPath: imageCacheDir)
        if !isCacheDirExist {
            do {
                try  FileManager.default.createDirectory(atPath: imageCacheDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                SyPrint("SyImageDownloaderCache dir create error")
            }
        }
    }
     
    fileprivate func getImageFromLocal(_ url: String) -> UIImage? {
        let path = imageCacheDir + "/" + url.xb_MD5
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    
    open func getImageWithUrl(urlString url: String, completeClosure closure: @escaping finishClosure) {
        //first get image from memory
        if let image = imageCache.object(forKey: url as AnyObject) {
            closure(image)
            return
        }
        
        //second get image from local
        if let image = getImageFromLocal(url) {
            //save to memory
            imageCache.setObject(image, forKey: url as AnyObject)
            
            closure(image)
            return
        }
        
        //last get image from network
        let queue = DispatchQueue(label: "www.3000uni.com", attributes: DispatchQueue.Attributes.concurrent)
        queue.async { [unowned self] in
            if let imageUrl = URL(string: url) {
                if let imageData = try? Data(contentsOf: imageUrl) {
                    //save to disk
                    try? imageData.write(to: URL(fileURLWithPath: self.imageCacheDir + "/" + url.xb_MD5), options: [.atomic])
                    
                    let image = UIImage(data: imageData)
                    
                    if image != nil {
                        //save to memory
                        self.imageCache.setObject(image!, forKey: url as AnyObject)
                    }
                    
                    DispatchQueue.main.async(execute: {
                        closure(image)
                    })
                    
                    return
                }
            }
        }
    }
    
    open func clearCachedImages() {
        do {
            let paths = try FileManager.default.contentsOfDirectory(atPath: imageCacheDir)
            for path in paths {
                try FileManager.default.removeItem(atPath: imageCacheDir + "/" + path)
            }
        } catch {
            SyPrint("SyImageDownloaderCache dir remove error")
        }
    }
}
