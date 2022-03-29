//
//  SyGuidePageView.swift
//
//  Created by 宋晓明 on 2019/4/1.
//  Copyright © 2019 wwsq. All rights reserved.
//  开屏引导图片、动图、视频

import UIKit
import Foundation

class SyGuidePageView: UIView {
    
    var imageArray:[String]?
    var guidePageView: UIScrollView!
    var imagePageControl: UIPageControl!
    var playerManager: SyVideoPlayerManager!
    var startButton: UIButton!
    
    ///   - imageNameArray: 引导页图片数组
    ///   - isHiddenSkipButton:  跳过按钮是否隐藏
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, imageNameArray:[String], isHiddenSkipButton: Bool) {
        self.init(frame: frame)
        self.imageArray = imageNameArray
        if self.imageArray == nil || self.imageArray?.count == 0 {
            return
        }
        self.addScrollView(frame: frame)
        self.addSkipButton(isHiddenSkipButton: isHiddenSkipButton)
        self.addPageControl()
        self.addImages()
    }
    
    convenience init(frame: CGRect, videoURL: URL, isHiddenSkipButton: Bool) {
        self.init(frame: frame)
        self.playerManager = SyVideoPlayerManager(playerFrame: frame, contentView: self)
        //            self.playerManager.delegate = self
        self.playerManager.playUrlStr = videoURL.absoluteString
        self.playerManager.seekToTime(0)// 跳转至第N秒的进度位置，从头播放则是0
        self.addSubview(self.playerManager.playerView)

        // 视频引导页进入按钮
        let movieStartButton = UIButton.init(frame: CGRect.init(x: 20, y: screenHeight()-70, width: screenWidth()-40, height: 40))
        movieStartButton.layer.cornerRadius = movieStartButton.bounds.size.height * 0.5
        movieStartButton.layer.borderColor = UIColor.white.cgColor
        movieStartButton.layer.borderWidth = 1
        movieStartButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        movieStartButton.setTitle(strCommon(key: "sy_begin"), for: .normal)
        movieStartButton.alpha = 0.0
        self.playerManager.playerView.addSubview(movieStartButton)
        movieStartButton.addTarget(self, action: #selector(skipButtonClick), for: .touchUpInside)
        UIView.animate(withDuration: 1.0) {
            movieStartButton.alpha = 1.0
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        SyPrint("deinit")
    }
}

extension SyGuidePageView {
    
    func addScrollView(frame: CGRect)  {
        self.guidePageView = UIScrollView.init(frame: frame)
        guidePageView.backgroundColor = UIColor.lightGray
        guidePageView.contentSize = CGSize.init(width: screenWidth() * (CGFloat)((self.imageArray?.count)!), height: screenHeight())
        guidePageView.bounces = false
        guidePageView.alpha = 1.0
        guidePageView.isPagingEnabled = true
        guidePageView.showsHorizontalScrollIndicator = false
        guidePageView.delegate = self
        self.addSubview(guidePageView)
    }
    
    // 跳过按钮
    func addSkipButton(isHiddenSkipButton: Bool) -> Void {
        if isHiddenSkipButton {
            return
        }
        let skipButton = UIButton.init(frame: CGRect.init(x: screenWidth() - 60, y: 50, width: 50, height: 30))
        skipButton.setTitle(strCommon(key: "sy_skip_title"), for: .normal)
        skipButton.backgroundColor = UIColor.darkGray
        skipButton.setTitleColor(UIColor.white, for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        skipButton.layer.cornerRadius = skipButton.frame.size.height * 0.5
        skipButton.addTarget(self, action: #selector(self.skipButtonClick), for: .touchUpInside)
        self.addSubview(skipButton)
    }
    
    @objc func skipButtonClick() -> Void {
        UIView.animate(withDuration: 1, animations: {
            self.alpha = 0
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
    // 图片
    func addImages() -> Void {
        guard let imageArray = self.imageArray else {
            return
        }
        for i in 0..<imageArray.count {
            let imageView = UIImageView.init(frame: CGRect.init(x: screenWidth() * CGFloat(i), y: 0, width: screenWidth(), height: screenHeight()))
            imageView.contentMode = .scaleAspectFill
            let idString = (imageArray[i] as NSString).substring(from: imageArray[i].count - 3)
            if idString == "gif" {
                imageView.image = UIImage.gifImageWithName(imageArray[i])
                self.guidePageView.addSubview(imageView)
            } else {
                imageView.image = UIImage.init(named: imageArray[i])
                self.guidePageView.addSubview(imageView)
            }
            
            // 在最后一张图片上显示开始体验按钮
            if i == imageArray.count - 1 {
                imageView.isUserInteractionEnabled = true
                self.startButton = UIButton.init(frame: CGRect.init(x: (self.frame.size.width - self.frame.size.width * 0.6) * 0.5, y: self.imagePageControl.frame.minY - 40, width: self.frame.size.width * 0.6, height: 40))
                self.startButton.backgroundColor = UIColor.clear
                self.startButton.setTitle(strCommon(key: "sy_begin"), for: .normal)
                self.startButton.setTitleColor(UIColor.gray, for: .normal)
                self.startButton.layer.cornerRadius = self.startButton.bounds.size.height * 0.5
                self.startButton.layer.borderColor = UIColor.gray.cgColor
                self.startButton.layer.borderWidth = 1
                self.startButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                self.startButton.addTarget(self, action: #selector(self.skipButtonClick), for: .touchUpInside)
                imageView.addSubview(self.startButton)
            }
        }
    }
    func addPageControl() -> Void {
        // 设置引导页上的页面控制器
        self.imagePageControl = UIPageControl.init(frame: CGRect.init(x: 0, y: screenHeight() - 40, width: screenWidth(), height: 40))
        self.imagePageControl.currentPage = 0
        self.imagePageControl.backgroundColor = UIColor.clear
        self.imagePageControl.numberOfPages = self.imageArray?.count ?? 0
        self.imagePageControl.pageIndicatorTintColor = UIColor.gray
        self.imagePageControl.isUserInteractionEnabled = false
        self.imagePageControl.currentPageIndicatorTintColor = UIColor.white
        self.addSubview(self.imagePageControl)
    }
}
// MARK: - /************************代理方法************************/
extension SyGuidePageView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        self.imagePageControl?.currentPage = Int(page)
        guard let imageArray = self.imageArray else {
            return
        }
        if Int(page) == imageArray.count - 1 {
            UIView.animate(withDuration: 1) {
                self.startButton.alpha = 1
            }
        }
    }
    
}
