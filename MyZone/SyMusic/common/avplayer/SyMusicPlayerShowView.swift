//
//  SyMusicPlayerShowView.swift
//  SyMusic
//
//  Created by sxm on 2020/5/15.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import LTMorphingLabel

extension SyMusicPlayerShowView {
    @objc
    func playBarChangePlayStateWith(notif : Notification){
        //let url = notif.userInfo?[CurrentPlayUrl]
        if let type = notif.userInfo?[PlayType] as? SyMusicPlayerManagerType,type != .PlayTypeLine {
            self.tView?.pauseTimer()
            self.playerShowViewProgress.progress = 0.0
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "play.circle") ,for: .normal)
        }
        guard let state = notif.userInfo?[SyMusicPlayerManagerState] as? AVPlayerPlayState else {return}
        switch state {
        case .AVPlayerPlayStatePreparing,.AVPlayerPlayStateBeigin:
            self.tView?.goOnTimer()
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "pause.circle"), for: .normal)
        case .AVPlayerPlayStatePlaying:
            self.tView?.goOnTimer()
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "pause.circle"), for: .normal)
        case .AVPlayerPlayStatePause:
            self.tView?.pauseTimer()
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "play.circle"), for: .normal)
        case .AVPlayerPlayStateEnd:
            self.tView?.pauseTimer()
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "play.circle"), for: .normal)
        case .AVPlayerPlayStateNotPlay:
            self.tView?.pauseTimer()
            self.playerShowViewProgress.progress = 0.0
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "play.circle"), for: .normal)
        case .AVPlayerPlayStateBufferEmpty:
            SyPrint("没有缓存了不可以播放.......(2)")
        case .AVPlayerPlayStateBufferToKeepUp:
            SyPrint("有缓存了可以播放了.......(2)")
        case .AVPlayerPlayStateseekToZeroBeforePlay:
            self.playerShowViewProgress.progress = 0.0
        default:
            self.tView?.pauseTimer()
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "play.circle"), for: .normal)
        }
    }
}

class turnView: UIView, SyMusicPlayerManagerDelegate {
    
    func updateProgressWith(progress: Float) {
        if progressView != nil {
            self.progressView?.progress = progress
        }
    }
    
    func changeMusicToIndex(index: Int) {
        SyPrint("///")
    }
    
    func updateBufferProgress(progress: Float) {
        SyPrint("///")
    }
    
    fileprivate var angle: CGFloat = 0
    //timer
    fileprivate var timer: Timer?
    
    open var turnImageView: UIImageView?
    open var progressView: UIProgressView?
    
    //MARK: - action
    @objc fileprivate func timerAction() {
        if SyMusicPlayerManager.getSharedInstance().isPlay {
//            SyPrint("底部viewShow-->>")
            let endAngle = CGAffineTransform(rotationAngle: self.angle * CGFloat((Double.pi / 180.0)))
            UIView.animate(withDuration: 0.05, delay: 0, options: .curveLinear, animations: {
                self.turnImageView?.transform = endAngle
            }) { (isFinished) in
                self.angle += 2
            }
        }
    }
    
    @objc open func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func stopTimer() {
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
    }
    
    public func pauseTimer() {
        if self.timer != nil {
            self.timer!.fireDate = NSDate.distantFuture
        }
    }
    
    public func goOnTimer() {
        if self.timer != nil {
            self.timer!.fireDate = NSDate.distantPast
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addNotification()
    }
    
    convenience init(frame: CGRect, imageView: UIImageView, _ progressView: UIProgressView?) {
        self.init(frame: frame)
        self.turnImageView = imageView
        if progressView != nil {
            self.progressView = progressView
            SyMusicPlayerManager.getSharedInstance().delegate = self
        }else{
            SyMusicPlayerManager.getSharedInstance().delegate = nil
        }
    }
    
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(stopTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startTimer), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    fileprivate func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//底部播放view
class SyMusicPlayerShowView: UIView{
    public var star: MusicStar!
    var tView: turnView?
    
    lazy var playerShowViewCloseBtn: UIButton = {
        var btn = buttonWithImageFrame(frame: CGRect(x: 10, y: 15, width: 20, height: 20), imageName:sfImage(name: "bonjour"), tag: 0, target: self, action: #selector(btnAction(sender:)))
        return btn
    }()
    
    lazy var playerShowViewHeaderImage: UIImageView = {
        var headerImageView = UIImageView(frame: CGRect(x: playerShowViewCloseBtn.frame.maxX + 10, y: 5, width: 40, height: 40))
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.layer.mask = headerImageView.roundCorner(imageView: headerImageView)
        headerImageView.clipsToBounds = true
        headerImageView.isUserInteractionEnabled = true
        headerImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapAction(sender:))))
        return headerImageView
    }()
    
    lazy var playerShowViewTitleLab: LTMorphingLabel = {
        let lab = LTMorphingLabel(frame: CGRect(x: playerShowViewHeaderImage.frame.maxX + 2, y: 5, width: self.frame.size.width - 60 - playerShowViewHeaderImage.frame.maxX - 2, height: 40))
        lab.morphingDuration = 0.8
        lab.morphingEffect = LTMorphingEffect(rawValue: 3)!
        lab.isUserInteractionEnabled = true
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = .white
        lab.textAlignment = .center
        lab.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapAction(sender:))))
        return lab
    }()
    
    
    lazy var playerShowViewPlayBtn: UIButton = {
        return buttonWithImageFrame(frame: CGRect(x: self.frame.size.width - 50, y: 10, width: 30, height: 30), imageName: SyMusicPlayerManager.getSharedInstance().isPlay == true ? sfImage(name: "pause.circle") : sfImage(name: "play.circle"), tag: 1, target: self, action: #selector(btnAction(sender:)))
    }()
    
    //播放进度条
    lazy var playerShowViewProgress: UIProgressView = {
        let p = UIProgressView(frame: CGRect(x: 0, y: self.bounds.size.height - 1.5, width: self.bounds.size.width, height: 10))
        p.transform = CGAffineTransform(scaleX: 1.0, y: 0.7)
        p.progressViewStyle = .default
        p.progress = 0.0
        p.trackTintColor = rgbWithValue(r: 220, g: 220, b: 220, alpha: 0.2)
        p.progressTintColor = .white
        p.layer.cornerRadius = 2
        return p
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, isShow: Bool, star: MusicStar) {
        self.init(frame: frame)
        self.star = star
        NotificationCenter.default.addObserver(self, selector: #selector(playBarChangePlayStateWith(notif:)), name: NSNotification.Name(rawValue: SyMusicPlayerManagerState), object: nil)
        
        self.layer.backgroundColor = UIColor.darkGray.cgColor
        self.layer.shadowColor = UIColor.white.cgColor //阴影背景
        self.layer.shadowOpacity = 0.1
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: self.frame.size.height + 2))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height + 2))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        self.layer.shadowPath = path.cgPath
        
        self.layer.cornerRadius = 2
        self.backgroundColor = .clear//themeColor()
        self.addSubview(playerShowViewCloseBtn)
        self.addSubview(playerShowViewHeaderImage)
        self.addSubview(playerShowViewTitleLab)
        self.addSubview(playerShowViewPlayBtn)
        self.addSubview(playerShowViewProgress)
        if isShow {
            self.tView = turnView(frame: CGRect.zero, imageView: self.playerShowViewHeaderImage, nil)
            self.tView?.startTimer()
        }
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        self.openView()
    }
    
    @objc func btnAction(sender: UIButton) {
        switch sender.tag {
        case 0:
            self.tView?.removeNotification()
            NotificationCenter.default.removeObserver(self)
            
            UIView.animate(withDuration: 1, animations: {
                self.tView?.stopTimer()
                SyMusicPlayerManager.getSharedInstance().stop()
                //销毁音频播放
                SyMusicPlayerManager.avPlayerDestroy()
                userDefaultsSetValue(value: "0", key: voicePlayKey())
                self.alpha = 0
                //去除远程控制
                UIApplication.shared.endReceivingRemoteControlEvents()
            }, completion: { (isCompletion) in
                self.removeFromSuperview()
            })
        case 1:
            if SyMusicPlayerManager.getSharedInstance().isPlay {
                self.tView?.pauseTimer()
                self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "play.circle"), for: .normal)
                SyMusicPlayerManager.getSharedInstance().player.pause()
                SyMusicPlayerManager.getSharedInstance().isPlay = false
            }else{
                self.tView?.goOnTimer()
                self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "pause.circle"), for: .normal)
                SyMusicPlayerManager.getSharedInstance().play()
            }
        default:
            break
        }
    }
    
    func openView() {
        self.tView?.pauseTimer()
        if !SyMusicPlayerManager.getSharedInstance().isPlay {
            SyMusicPlayerManager.getSharedInstance().play()
        }
        let vc = SyMusicPlayVC()
        vc.star = self.star
//        vc.musicItem = SyMusicPlayerManager.getSharedInstance().musicItem
        vc.modalPresentationStyle = .fullScreen
        currentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
