//
//  SyLaunchManager.swift
//  wwsq
//
//  Created by sxm-wwsq on 2017/7/13.
//  Copyright © 2017年 wwsq. All rights reserved.
//

import Foundation
import XHLaunchAd
import SafariServices

class SyLaunchManager: NSObject {
    
    //单例
    private static let sharedLaunch: SyLaunchManager = SyLaunchManager()
    class func sharedInstance() -> SyLaunchManager {
        return sharedLaunch
    }
    
    override init() {
        super.init()
        let notificationCenter = NotificationCenter.default
        let operationQueue = OperationQueue.main
        notificationCenter.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: operationQueue) { notification in
            XHLaunchAd.setWaitDataDuration(3)
            self.setupLaunch()
        }
    }
  
    func setupLaunch() {
        /*SyRequestCollection.getSharedInstance().launchDataRequest { (dic) in
            let model = SyLaunchModel()
            model.initWithDictionary(dic: dic)
            if (model.fileType == "video") {
                self.videoLauchAd(model: model)
            }else if (model.fileType == "img") {
                self.imageLaunchAd(model: model)
            }
        }*/
        
        let model = SyLaunchModel()
        model.content = "item_screen_icon.jpg"
        model.screenTime = 3
        self.imageLaunchAd(model: model)
    }
    
    func videoLauchAd(model: SyLaunchModel) {
        DispatchQueue.main.async{
            let videoAdconfiguration = XHLaunchVideoAdConfiguration()
            videoAdconfiguration.duration = model.screenTime
            videoAdconfiguration.frame = CGRect.init(x: 0, y: 0, width: screenWidth(), height: screenHeight())
            videoAdconfiguration.videoNameOrURLString = model.content
            videoAdconfiguration.videoGravity = .resizeAspectFill
            videoAdconfiguration.showFinishAnimate = .fadein
            videoAdconfiguration.showEnterForeground = false
            videoAdconfiguration.skipButtonType = .timeText
            XHLaunchAd.videoAd(with: videoAdconfiguration, delegate: self)
        }
    }
    
    func imageLaunchAd(model: SyLaunchModel) {
        DispatchQueue.main.async{
            let imageAdconfiguration = XHLaunchImageAdConfiguration()
            imageAdconfiguration.duration = model.screenTime
            imageAdconfiguration.frame = CGRect.init(x: 0, y: 0, width: screenWidth(), height: screenHeight())
            imageAdconfiguration.imageNameOrURLString = model.content
            imageAdconfiguration.imageOption = .default
            imageAdconfiguration.contentMode = .scaleAspectFill
            imageAdconfiguration.showFinishAnimate = .fadein
            imageAdconfiguration.skipButtonType = .timeText
            imageAdconfiguration.showEnterForeground = false
            XHLaunchAd.imageAd(with: imageAdconfiguration, delegate: self)
        }
    }
}

extension SyLaunchManager: XHLaunchAdDelegate {
    
    func xhLaunchAd(_ launchAd: XHLaunchAd, clickAtOpenModel openModel: Any, click clickPoint: CGPoint) -> Bool {
        guard let model = openModel as? SyLaunchModel else {
            return false
        }
        
        if model.openUrl.trimmingCharactersCount > 0 {
            let webViewController = SFSafariViewController.init(url: URL.init(string: model.openUrl)!)
            webViewController.preferredControlTintColor = .white
            webViewController.preferredBarTintColor = .black
            currentViewController()?.present(webViewController, animated: true, completion: nil)
        }
        return true
    }
    
    func xhLaunchAd(_ launchAd: XHLaunchAd, imageDownLoadFinish image: UIImage) {
        SyPrint("图片下载完成/或本地图片读取完成回调")
    }
    
    //视频本地读取/或下载完成回调
    func xhLaunchAd(_ launchAd: XHLaunchAd, videoDownLoadFinish pathURL: URL) {
        SyPrint("video下载/加载完成/保存path = \(pathURL.absoluteString)")
    }
    
    func xhLaunchAd(_ launchAd: XHLaunchAd, videoDownLoadProgress progress: Float, total: UInt64, current: UInt64) {
        SyPrint("总大小=\(total),已下载大小=\(current),下载进度=\(progress)")
    }
    
    //广告显示完成
    func xhLaunchShowFinish(_ launchAd: XHLaunchAd) {
        SyPrint("广告显示完成")
    }
}
