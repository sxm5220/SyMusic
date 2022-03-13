//
//  SyMainItem.swift
//  SyMusic
//
//  Created by sxm on 2021/5/7.
//  Copyright © 2021 wwsq. All rights reserved.
//

import Foundation

public enum MusicStar: String {
    case JayChou = "JayChou" //周杰伦
    case JokerXue = "JokerXue" //薛之谦
    case BackstreetBoys = "BackstreetBoys" //后街男孩
    case LeehomWang = "LeehomWang" //王力宏
}

struct SyMusicMessageItem: Codable {
    let musicM: SyMusicsItem
    var costTime: TimeInterval = 0
    var totalTime: TimeInterval = 0
    var isPlaying: Bool
}

struct SyMusicsItem: Codable {
    let id: String
    let category: String
    let name: String
    let icon: String
    let singerIcon: String
    let singer: String
    let lrcname: String
    let filename: String
}

struct SyLrcItem: Codable {
    var beginTime: TimeInterval = 0
    var endTime: TimeInterval = 0
    let lrcContent: String
}
