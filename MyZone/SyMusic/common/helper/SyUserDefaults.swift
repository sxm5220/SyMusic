//
//  SyUserDefaults.swift
//  SyMusic
//
//  Created by sxm on 2020/5/10.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import UIKit

func clearAllUserDefaultsData() {
    let userDefaults = UserDefaults.standard
    let dicData = userDefaults.dictionaryRepresentation()
    for keyValue in dicData {
        if keyValue.key != appVersionKey {
                userDefaults.removeObject(forKey: keyValue.key)
                userDefaults.synchronize()
        }
    }
}

func userDefaultsSetValue(value: Any?, key: String) {
    let newValue = value as AnyObject
    if newValue.boolValue != nil {
        UserDefaults.standard.set(value, forKey: key)
    }
}

func userDefaultsForString(forKey: String) -> String {
    let key = UserDefaults.standard.string(forKey: forKey)
    if key != nil {
        return key!
    }
    return ""
}

internal let appVersionKey = "app_last_version"

//播放收起来
internal let voicePlayKey = "voice_play_key"

//音频播放页面循环状态
internal let cycleVoiceStateKey = "cycle_voice_state_key"
