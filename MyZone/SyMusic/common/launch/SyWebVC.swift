//
//  SyWebVC.swift
//  SyMusic
//
//  Created by sxm on 2022/3/25.
//  Copyright © 2022 wwsq. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import XHLaunchAd

class SyWebVC: SyBaseVC {
    
    public var urlString: String?
    
    private var webView: WKWebView!
    
    private var progressView: UIProgressView!
    
    /*deinit {
         //如果你设置了APP从后台恢复时也显示广告,
         //当用户停留在广告详情页时,APP从后台恢复时,你不想再次显示启动广告,
         //请在广告详情控制器销毁时,发下面通知,告诉XHLaunchAd,广告详情页面已显示完
         
        NotificationCenter.default.post(name: NSNotification.Name.XHLaunchAdDetailPageShowFinish, object: nil)
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 如果你设置了APP从后台恢复时也显示广告,
        // 当用户停留在广告详情页时,APP从后台恢复时,你不想再次显示启动广告,
        // 请在广告详情控制器将要显示时,发下面通知,告诉XHLaunchAd,广告详情页面将要显示
        NotificationCenter.default.post(name: NSNotification.Name.XHLaunchAdDetailPageWillShow, object: nil)
    }*/
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.progressView.removeFromSuperview()
    }
    
    override func leftBarButtonAction(sender: UIButton) {
        if self.webView.canGoBack {
            self.webView.goBack()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isBackBar = true
        self.navigationController?.navigationBar.isTranslucent = true
        self.webView = WKWebView(frame: CGRect(x: 0, y: 0, width: screenWidth(), height: screenHeight()))
        self.webView.scrollView.backgroundColor = .black
        self.view.addSubview(self.webView)
        
//        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        guard let url = self.urlString else { return }
        self.webView.load(URLRequest(url: URL(string: url)!))
        
        self.progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: screenWidth(), height: 2))
        self.progressView.progressViewStyle = .bar
        self.progressView.progressTintColor = .white
        self.navigationController?.view.addSubview(self.progressView)
    }
    
    /*override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            guard let dic = change as? NSDictionary else { return }
            let pro = dic[NSKeyValueChangeKey.self]
            guard let progressValue = pro as? Float else { return }
            SyPrint("progressValue=>>\(progressValue)")
            //self.progressView.setProgress(progressValue, animated: true)
            if progressValue == 1.0 {
                DispatchQueue.main.async {
                    //self.progressView.setProgress(0.0, animated: false)
                }
            }
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }*/
}
