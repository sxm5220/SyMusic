//
//  SyMusicsModel.swift
//  SyMusic
//
//  Created by sxm on 2020/5/19.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation

class SyMusicMessageModel: NSObject {
    var musicM: SyMusicsModel?
    var costTime: TimeInterval = 0
    var totalTime: TimeInterval = 0
    var isPlaying: Bool = false
    var costTimeFormat: String {
        get {
            return Timer.getFormatTime(costTime)
        }
    }
    var totalTimeFormat: String {
        get {
            return Timer.getFormatTime(totalTime)
        }
    }
}

class SyLrcModel: NSObject {
    var beginTime: TimeInterval = 0
    var endTime: TimeInterval = 0
    var lrcContent: String = ""
}

class SyMusicsModel: NSObject {
    var id: String = ""
    var category: String = ""
    var name: String = ""
    var icon: String = ""
    var singerIcon: String = ""
    var singer: String = ""
    var lrcname: String = ""
    var filename: String = ""
    
    func initWithDictionary(dic: NSDictionary) {
        self.id = dicForValue(dic: dic, key: "id")
        self.category = dicForValue(dic: dic, key: "category")
        self.name = dicForValue(dic: dic, key: "name")
        self.icon = dicForValue(dic: dic, key: "icon")
        self.singerIcon = dicForValue(dic: dic, key: "singerIcon")
        self.singer = dicForValue(dic: dic, key: "singer")
        self.lrcname = dicForValue(dic: dic, key: "lrcname")
        self.filename = dicForValue(dic: dic, key: "filename")
    }
}
