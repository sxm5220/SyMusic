//
//  SyLaunchModel.swift
//  wwsq
//
//  Created by sxm-wwsq on 2017/7/13.
//  Copyright © 2017年 wwsq. All rights reserved.
//

import Foundation

class SyLaunchModel {
    var openUrl: String = ""
    var screenTime: Int = 3
    var content: String = ""
    
    func initWithDictionary(dic: NSDictionary) {
        self.openUrl = dicForValue(dic: dic, key: "openUrl")
        self.content = dicForValue(dic: dic, key: "content")
        self.screenTime = Int(dicForValue(dic: dic, key: "screenTime")) ?? 3
    }
}

