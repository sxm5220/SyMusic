//
//  AppDelegate.swift
//  SyMusic
//
//  Created by sxm on 2020/5/1.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        //开屏广告
        SyLaunchManager.sharedInstance().setupLaunch()
        
        //检测网络状态
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        
        self.window?.rootViewController = SyTabBarController()
        return true
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        //判断app是否需要升级
        //SyRequestCollection.getSharedInstance().appVersionRequest()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        //只有开启播放SQPlayerShowView 才会有远程控制
        if event?.type == .remoteControl && userDefaultsForString(forKey: voicePlayKey()) == "1" {
            switch event!.subtype {
            case .remoteControlPlay:
                SyAVPlayer.getSharedInstance().play()
            case .remoteControlPause:
                SyAVPlayer.getSharedInstance().pause()
            case .remoteControlNextTrack:
                SyAVPlayer.getSharedInstance().next()
            case .remoteControlPreviousTrack:
                SyAVPlayer.getSharedInstance().previous()
            case .remoteControlTogglePlayPause:
                if SyAVPlayer.getSharedInstance().isPlay {
                    SyAVPlayer.getSharedInstance().pause()
                } else {
                    SyAVPlayer.getSharedInstance().current()
                }
            default:
                break
            }
        }
    }
}

