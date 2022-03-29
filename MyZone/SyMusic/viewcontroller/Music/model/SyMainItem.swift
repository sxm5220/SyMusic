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

//作曲家
struct SyComposerItem {
    let composerId: String
    let albums: [SyAlbumItem]
}

struct SyAlbumItem {
    let albumId: String //专辑id
    let albumName: String //专辑名称
    let albumImage: String //专辑图片
    let productionCompany: String //制作公司
    let issueDate: String //发行日期
    let albumData: [SyMusicsItem] //歌曲列表
}

struct SyMusicsItem: Codable {
    let id: String //id
    let musicName: String //歌曲名称
    let composerName: String //编曲人
    let lyricistName: String //作词人
    let duration: String //歌曲时长
}

struct SyMusicMessageItem: Codable {
    let musicM: SyMusicsItem
    var costTime: TimeInterval = 0
    var totalTime: TimeInterval = 0
    var isPlaying: Bool
}

struct SyLrcItem: Codable {
    var beginTime: TimeInterval = 0
    var endTime: TimeInterval = 0
    let lrcContent: String
}
