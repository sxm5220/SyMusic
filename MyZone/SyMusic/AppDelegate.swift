//
//  AppDelegate.swift
//  SyMusic
//
//  Created by sxm on 2020/5/1.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate { //,GADFullScreenContentDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = UIViewController()
        
        /*/Google Ads
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        // Ads上显示 ‘Test mode’ 正式版发布时，需要注视掉
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =
            [ "2077ef9a63d2b398840261c8221a0c9b" ]
        
        //开屏显示Ads
        SyAppOpenAdManager.shared.loadAd()
        
        //ads版本
        //GADMobileAds.sharedInstance().sdkVersion
        
        //手动开启Ads
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [GADSimulatorID as String]
        GADMobileAds.sharedInstance().start()*/
        
        //开屏广告
        SyLaunchManager.sharedInstance().setupLaunch()
        
        //检测网络状态
//        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        
        self.window?.rootViewController = SyTabBarController()
        return true
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        //判断app是否需要升级
        //SyRequestCollection.getSharedInstance().appVersionRequest()
    }
    
    /*/从后台打开
    func applicationDidBecomeActive(_ application: UIApplication) {
        //开屏显示Ads
        let rootVC = application.windows.first(
            where: { $0.isKeyWindow })?.rootViewController
        if let rootViewController = rootVC {
            // Do not show app open ad if the current view controller is SplashViewController.
            if rootViewController is SySplashVC {
                return
            }
            SyAppOpenAdManager.shared.showAdIfAvailable(viewController: rootViewController)
        }
    }*/
    
    override func remoteControlReceived(with event: UIEvent?) {
        //只有开启播放SQPlayerShowView 才会有远程控制
        if event?.type == .remoteControl && userDefaultsForString(forKey: voicePlayKey) == "1" {
            switch event!.subtype {
            case .remoteControlPlay:
                SyMusicPlayerManager.getSharedInstance().play()
            case .remoteControlPause:
                SyMusicPlayerManager.getSharedInstance().pause()
            case .remoteControlNextTrack:
                SyMusicPlayerManager.getSharedInstance().next()
            case .remoteControlPreviousTrack:
                SyMusicPlayerManager.getSharedInstance().previous()
            case .remoteControlTogglePlayPause:
                if SyMusicPlayerManager.getSharedInstance().isPlay {
                    SyMusicPlayerManager.getSharedInstance().pause()
                } else {
                    SyMusicPlayerManager.getSharedInstance().current()
                }
            default:
                break
            }
        }
    }
}

