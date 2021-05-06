//
//  SyProgressHUD.swift
//  SyMusic
//
//  Created by sxm on 2020/5/10.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import SVProgressHUD

//根据文字长度指示器显示时长
func calculateHideTime(text: String) -> TimeInterval {
    let length = text.maximumLengthOfBytes(using: String.Encoding(rawValue: String.Encoding.utf16.rawValue))
//    SyPrint( length)
    return TimeInterval(Double(length) * 0.04 + 0.1)
}

//延时1秒执行
func progressHUDStatusShowWithTimeInterval(time: TimeInterval) {
    SVProgressHUD.show()
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
        progressHUDDismiss()
    }
}

func progressHUDStatusShowTipWithTimeInterval(tipStr: String, time: TimeInterval) {
    SVProgressHUD.show(withStatus: tipStr)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
        progressHUDDismiss()
    }
}

func progressHUDShowWarningWithStatus(status: String) {
    if status == "<null>" {
        return
    }
    SVProgressHUD.showInfo(withStatus: status)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + calculateHideTime(text: status)) {
        progressHUDDismiss()
    }
}

func progressHUDShowSuccessWithStatus(status: String) {
    SVProgressHUD.showSuccess(withStatus: status)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + calculateHideTime(text: status)) {
        progressHUDDismiss()
    }
}

func progressHUDShowErrorWithStatus(status: String) {
    SVProgressHUD.showError(withStatus: status)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + calculateHideTime(text: status)) {
        progressHUDDismiss()
    }
}

func progressHUDShowErrorWithNetwork(error: NSError) {
    progressHUDShowErrorWithStatus(status: networkError(error: error))
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + calculateHideTime(text: networkError(error: error))) {
        progressHUDDismiss()
    }
}

func progressHUDDismiss() {
    SVProgressHUD.dismiss()
}

