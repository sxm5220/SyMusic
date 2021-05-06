//
//  SyCycleViewImageModel.swift
//  wwsq
//
//  Created by 宋晓明 on 2018/4/20.
//  Copyright © 2018年 wwsq. All rights reserved.
//

import Foundation
import UIKit

open class SyCycleViewImageModel: NSObject {
    ///图片对应的标题
    var title: String?
    
    ///图片的描述
    var describe: String?
    
    ///图片对应的链接
    var imageUrlString: String?
    
    ///本地要展示的图片
    var localImage: UIImage?
    
    override init() {
        super.init()
    }
    
    init (title: String?, describe: String?, imageUrlString: String?, localImage: UIImage?) {
        self.title = title
        self.describe = describe
        self.imageUrlString = imageUrlString
        self.localImage = localImage
    }
    
    init (imageUrlString: String?, localImage: UIImage?) {
        self.imageUrlString = imageUrlString
        self.localImage = localImage
    }
    
    init(imageUrlString: String?) {
        self.imageUrlString = imageUrlString
    }
    
    init(localImage: UIImage?) {
        self.localImage = localImage
    }
}
