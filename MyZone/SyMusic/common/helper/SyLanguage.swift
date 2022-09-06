//
//  SyLanguage.swift
//  demoBySwift
//
//  Created by sxm on 2017/5/5.
//  Copyright © 2017年 sxm. All rights reserved.
//

import Foundation
import UIKit

//系统当前语言
internal let language = Locale.preferredLanguages.first!

//中文
internal let isChinese = language.hasPrefix("zh")

//英语
internal let isEnglish = language.hasPrefix("en")

//法语
internal let isFrancais = language.hasPrefix("fr")

//日语
internal let isJapanese = language.hasPrefix("ja")

//韩语
internal let isKorean = language.hasPrefix("ko")

//阿拉伯语
internal let isArabic = language.hasPrefix("ar")

//多语言
func strFromTable(table: String, key: String) -> String {
    return NSLocalizedString(key, tableName: table, bundle: Bundle.main, value: "", comment: "")
}

func strCommon(key: String) -> String {
    return strFromTable(table: "common", key: key)
}

