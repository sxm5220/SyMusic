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
        
        //图片开屏广告 - 本地数据
        //self.imageBylocaldata(duration: 2,localImage: "launchAd_image.gif", openUrl: "https://sxm5220.github.io")
        
        //图片开屏广告 - 网络数据
//        self.imageByNetworkdata()
        
        //视频开屏广告 - 本地数据
        self.videoBylocaldata(duration: 2,localVideo: "launchAd_video.mp4", openUrl: "https://sxm5220.github.io")
    }
    
    //图片开屏广告 - 本地数据
    private func imageBylocaldata(duration: Int,localImage: String, openUrl: String) {
        //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
        XHLaunchAd.setLaunch(.launchImage)
        //配置广告数据
        let imageAdconfiguration = XHLaunchImageAdConfiguration()
        //广告停留时间
        imageAdconfiguration.duration = duration
        //广告frame
        imageAdconfiguration.frame = CGRect(x: 0, y: 0, width: screenWidth(), height: screenHeight() * 0.8)
        //广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
        //注意本地广告图片,直接放在工程目录,不要放在Assets里面,否则不识别,此处涉及到内存优化
        imageAdconfiguration.imageNameOrURLString = localImage
        //设置GIF动图是否只循环播放一次(仅对动图设置有效)
        imageAdconfiguration.gifImageCycleOnce = false
        //图片填充模式
        imageAdconfiguration.contentMode = .scaleAspectFill
        //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
        imageAdconfiguration.openModel = openUrl
        //广告显示完成动画
        imageAdconfiguration.showFinishAnimate = .fadein //普通淡入
        //广告显示完成动画时间
        imageAdconfiguration.showFinishAnimateTime = 0.8
        //跳过按钮类型
        imageAdconfiguration.skipButtonType = .timeText
        //自定义跳转按钮
//        imageAdconfiguration.customSkipView = self.customSkipView()
        //后台返回时,是否显示广告
        imageAdconfiguration.showEnterForeground = false
        //设置要添加的子视图(可选)
        //imageAdconfiguration.subViews = self.launchAdSubViews()
        //显示开屏广告
        XHLaunchAd.imageAd(with: imageAdconfiguration, delegate: self)
    }
    
    //图片开屏广告 - 网络数据
    private func imageByNetworkdata() {
        //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
        XHLaunchAd.setLaunch(.launchImage)
        //1.因为数据请求是异步的,请在数据请求前,调用下面方法配置数据等待时间.
        //2.设为2即表示:启动页将停留2s等待服务器返回广告数据,2s内等到广告数据,将正常显示广告,否则将不显示
        //3.数据获取成功,配置广告数据后,自动结束等待,显示广告
        //注意:请求广告数据前,必须设置此属性,否则会先进入window的的根控制器
        XHLaunchAd.setWaitDataDuration(2)
        //广告数据请求
        //TODO: 此处请求网络获取广告数据
        //配置广告数据
        let imageAdconfiguration = XHLaunchImageAdConfiguration()
        //广告停留时间
        imageAdconfiguration.duration = 5//TODO:获取网络给定时间
        //广告frame
        imageAdconfiguration.frame = CGRect(x: 0, y: 0, width: screenWidth(), height: screenHeight() * 0.8)
        //广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
        //注意本地广告图片,直接放在工程目录,不要放在Assets里面,否则不识别,此处涉及到内存优化
        imageAdconfiguration.imageNameOrURLString = ""//TODO:获取网络给定图片显示url
        //设置GIF动图是否只循环播放一次(仅对动图设置有效)
        imageAdconfiguration.gifImageCycleOnce = false
        //为告展示效果更好,可设置为XHLaunchAdImageCacheInBackground,先缓存,下次显示
        imageAdconfiguration.imageOption = .default
        //图片填充模式
        imageAdconfiguration.contentMode = .scaleAspectFill
        //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
        imageAdconfiguration.openModel = ""//TODO:网络给定点击打开url
        //广告显示完成动画
        imageAdconfiguration.showFinishAnimate = .fadein //普通淡入
        //广告显示完成动画时间
        imageAdconfiguration.showFinishAnimateTime = 0.8
        //跳过按钮类型
        imageAdconfiguration.skipButtonType = .timeText
        //后台返回时,是否显示广告
        imageAdconfiguration.showEnterForeground = false
        //图片已缓存 - 显示一个 "已预载" 视图 (可选)
        if XHLaunchAd.checkImageInCache(with: URL(string: "")!) {
            //设置要添加的自定义视图(可选)
            imageAdconfiguration.subViews = self.launchAdSubViewsAlreadyView()
        }
        XHLaunchAd.imageAd(with: imageAdconfiguration, delegate: self)
    }
    
    //视频开屏广告 - 本地数据
    private func videoBylocaldata(duration: Int,localVideo: String, openUrl: String) {
        //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
        XHLaunchAd.setLaunch(.launchImage)
        //配置广告数据
        let videoAdconfiguration = XHLaunchVideoAdConfiguration()
        //广告停留时间
        videoAdconfiguration.duration = duration
        //广告frame
        videoAdconfiguration.frame = CGRect(x: 0, y: 0, width: screenWidth(), height: screenHeight())
        //广告视频URLString/或本地视频名(请带上后缀)
        videoAdconfiguration.videoNameOrURLString = localVideo
        //是否关闭音频
        videoAdconfiguration.muted = false
        //视频填充模式
        videoAdconfiguration.videoGravity = .resizeAspectFill
        //是否只循环播放一次
        videoAdconfiguration.videoCycleOnce = false
        //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
        videoAdconfiguration.openModel = openUrl
        //跳过按钮类型
        videoAdconfiguration.skipButtonType = .timeText
        //广告显示完成动画
        videoAdconfiguration.showFinishAnimate = .fadein
        //广告显示完成动画时间
        videoAdconfiguration.showFinishAnimateTime = 0.8
        //后台返回时,是否显示广告
        videoAdconfiguration.showEnterForeground = false
        //设置要添加的子视图(可选)
//        videoAdconfiguration.subViews = self.launchAdSubViews()
        //显示开屏广告
        XHLaunchAd.videoAd(with: videoAdconfiguration, delegate: self)
    }
    
    //视频开屏广告 - 网络数据
    private func videoByNetworkdata() {
        //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
        XHLaunchAd.setLaunch(.launchImage)
        //1.因为数据请求是异步的,请在数据请求前,调用下面方法配置数据等待时间.
        //2.设为2即表示:启动页将停留2s等待服务器返回广告数据,2s内等到广告数据,将正常显示广告,否则将不显示
        //3.数据获取成功,配置广告数据后,自动结束等待,显示广告
        //注意:请求广告数据前,必须设置此属性,否则会先进入window的的根控制器
        XHLaunchAd.setWaitDataDuration(2)
        //广告数据请求
        //TODO:此处请求网络
        /*[Network getLaunchAdVideoDataSuccess:^(NSDictionary * response) {
         NSLog(@"广告数据 = %@",response);
         //广告数据转模型
         LaunchAdModel *model = [[LaunchAdModel alloc] initWithDict:response[@"data"]];*/
        
        //配置广告数据
        let videoAdconfiguration = XHLaunchVideoAdConfiguration()
        //广告停留时间
        videoAdconfiguration.duration = 5 //TODO：获取停留时间
        //广告frame
        videoAdconfiguration.frame = CGRect(x: 0, y: 0, width: screenWidth(), height: screenHeight())
        //广告视频URLString/或本地视频名(请带上后缀)
        //注意:视频广告只支持先缓存,下次显示(看效果请二次运行)
        videoAdconfiguration.videoNameOrURLString = "" //TODO: 视频url
        //是否关闭音频
        videoAdconfiguration.muted = false
        //视频填充模式
        videoAdconfiguration.videoGravity = .resizeAspectFill
        //是否只循环播放一次
        videoAdconfiguration.videoCycleOnce = false
        //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
        videoAdconfiguration.openModel = "" //TODO: 视频点击打开链接
        //跳过按钮类型
        videoAdconfiguration.skipButtonType = .timeText
        //广告显示完成动画
        videoAdconfiguration.showFinishAnimate = .fadein
        //广告显示完成动画时间
        videoAdconfiguration.showFinishAnimateTime = 0.8
        //后台返回时,是否显示广告
        videoAdconfiguration.showEnterForeground = false
        //视频已缓存 - 显示一个 "已预载" 视图 (可选)
        if XHLaunchAd.checkVideoInCache(with: URL(string: "")!) {
            //设置要添加的自定义视图(可选)
            videoAdconfiguration.subViews = self.launchAdSubViewsAlreadyView()
        }
        //显示开屏广告
        XHLaunchAd.videoAd(with: videoAdconfiguration, delegate: self)
    }
    
    private func launchAdSubViewsAlreadyView() -> [UIView] {
        let yValue: CGFloat = 46
        let lab = SyLabel(frame: CGRect(x: screenWidth() - 140, y: yValue, width: 60.0, height: 30.0), text: strCommon(key: "sy_loaded"), textColor: .white, font: .systemFont(ofSize: 12), textAlignment: .center)
        lab.layer.cornerRadius = 5
        lab.layer.masksToBounds = true
        lab.backgroundColor = rgbWithValue(r: 0, g: 0, b: 0, alpha: 0.5)
        return [lab]
    }
    
    private func launchAdSubViews() -> [UIView] {
        let yValue: CGFloat = 80
        let lab = SyLabel(frame: CGRect(x: screenWidth() - 170, y: yValue, width: 60.0, height: 30.0), text: strCommon(key: "sy_loaded"), textColor: .white, font: .systemFont(ofSize: 12), textAlignment: .center)
        lab.layer.cornerRadius = 5
        lab.layer.masksToBounds = true
        lab.backgroundColor = rgbWithValue(r: 0, g: 0, b: 0, alpha: 0.5)
        return [lab]
    }
    
    fileprivate func customSkipView() -> UIView {
        let btn = buttonWithTitleFrame(frame: CGRect(x: screenWidth() - 100, y: 80, width: 80, height: 40), title: "跳过", titleColor: .white, backgroundColor: .lightGray, cornerRadius: 20, tag: 0, target: self, action: #selector(btnAction(sender:)))
        return btn
    }
    
    @objc func btnAction(sender: UIButton) {
        XHLaunchAd.removeAnd(animated: true)
    }
}

extension SyLaunchManager: XHLaunchAdDelegate {
    
    func xhLaunchAd(_ launchAd: XHLaunchAd, customSkip customSkipView: UIView, duration: Int) {
        let btn = customSkipView as? UIButton
        btn?.setTitle("自定义\(duration)", for: .normal)
    }
    
    func xhLaunchAd(_ launchAd: XHLaunchAd, clickAtOpenModel openModel: Any, click clickPoint: CGPoint) -> Bool {
        /*guard let openUrl = openModel as? String else {
            return false
        }
        
        if openUrl.trimmingCharactersCount > 0 {
            let webViewController = SFSafariViewController.init(url: URL.init(string: openUrl)!)
            webViewController.preferredControlTintColor = .white
            webViewController.preferredBarTintColor = .black
            currentViewController()?.navigationController?.pushViewController(webViewController, animated: true)
        }*/
        /*guard let model = openModel as? SyLaunchModel else {
            return false
        }
        
        if model.openUrl.trimmingCharactersCount > 0 {
            let webViewController = SFSafariViewController.init(url: URL.init(string: model.openUrl)!)
            webViewController.preferredControlTintColor = .white
            webViewController.preferredBarTintColor = .black
            currentViewController()?.present(webViewController, animated: true, completion: nil)
        }*/
        return true //true移除广告,false不移除广告
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
