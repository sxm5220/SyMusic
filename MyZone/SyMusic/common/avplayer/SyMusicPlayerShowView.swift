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
        //付费模式下不可播放
        if let type = notif.userInfo?[PlayType] as? SyMusicPlayerManagerType,type == .PlayTypePay {
            self.pauseTimer()
            self.playerShowViewProgress.progress = 0.0
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "play.circle") ,for: .normal)
        }
        guard let state = notif.userInfo?[SyMusicPlayerManagerState] as? AVPlayerPlayState else {return}
        switch state {
        case .AVPlayerPlayStatePreparing,.AVPlayerPlayStateBeigin:
            self.goOnTimer()
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "pause.circle"), for: .normal)
        case .AVPlayerPlayStatePlaying:
            self.goOnTimer()
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "pause.circle"), for: .normal)
        case .AVPlayerPlayStatePause:
            self.pauseTimer()
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "play.circle"), for: .normal)
        case .AVPlayerPlayStateEnd:
            self.pauseTimer()
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "play.circle"), for: .normal)
        case .AVPlayerPlayStateNotPlay:
            self.pauseTimer()
            self.playerShowViewProgress.progress = 0.0
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "play.circle"), for: .normal)
        case .AVPlayerPlayStateBufferEmpty:
            SyPrint("没有缓存了不可以播放.......(2)")
        case .AVPlayerPlayStateBufferToKeepUp:
            SyPrint("有缓存了可以播放了.......(2)")
        case .AVPlayerPlayStateseekToZeroBeforePlay:
            self.playerShowViewProgress.progress = 0.0
        default:
            self.pauseTimer()
            self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "play.circle"), for: .normal)
        }
    }
}

extension SyMusicPlayerShowView: SyMusicPlayerManagerDelegate {
    
    func updateProgressWith(progress: Float, currentTime: TimeInterval) {
        self.playerShowViewProgress.progress = progress
        
        let image = SyMusicPlayerManager.getSharedInstance().albumItem?.albumImage ?? ""
        self.playerShowViewHeaderImage.image = UIImage(named: image)
        
        let lrcName = SyMusicPlayerManager.getSharedInstance().musicItem?.musicName ?? ""
        let rowLrcM = SyMusicPlayerManager.getSharedInstance().getCurrentLrcM(currentTime, lrcMs: SyMusicPlayerManager.getSharedInstance().getLrcMs(lrcName))
        let lrcM = rowLrcM.lrcM
        self.playerShowViewTitleLab.text = lrcM?.lrcContent//更新歌词，固定的单行歌词
    }
    
    func changeMusicToIndex(index: Int) {
        SyPrint("///")
    }
    
    func updateBufferProgress(progress: Float) {
        SyPrint("///")
    }
}

//底部播放view
class SyMusicPlayerShowView: UIView{
    public var star: MusicStar!
    private var angle: CGFloat = 0
    private var timer: Timer?
    
    lazy var playerShowViewCloseBtn: UIButton = {
        var btn = buttonWithImageFrame(imageName:sfImage(name: "bonjour"), tag: 0, target: self, action: #selector(btnAction(sender:)))
        return btn
    }()
    
    lazy var playerShowViewHeaderImage: UIImageView = {
        var headerImageView = UIImageView()
        headerImageView.frame = CGRect(x: 40, y: 5, width: 40, height: 40)
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.layer.mask = headerImageView.roundCorner(imageView: headerImageView)
        headerImageView.clipsToBounds = true
        headerImageView.isUserInteractionEnabled = true
        headerImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapAction(sender:))))
        return headerImageView
    }()
    
    lazy var playerShowViewTitleLab: LTMorphingLabel = {
        let lab = LTMorphingLabel()
        lab.morphingDuration = 0.8
        lab.morphingEffect = LTMorphingEffect(rawValue: 3)!
        lab.isUserInteractionEnabled = true
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = .white
        lab.backgroundColor = .clear
        lab.textAlignment = .left
        lab.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapAction(sender:))))
        return lab
    }()
    
    
    lazy var playerShowViewPlayBtn: UIButton = {
        let btn = buttonWithImageFrame(imageName: SyMusicPlayerManager.getSharedInstance().isPlay == true ? sfImage(name: "pause.circle") : sfImage(name: "play.circle"), tag: 1, target: self, action: #selector(btnAction(sender:)))
        return btn
    }()
    
    //播放进度条
    lazy var playerShowViewProgress: UIProgressView = {
        let p = UIProgressView()
        p.transform = CGAffineTransform(scaleX: 1.0, y: 0.7)
        p.progressViewStyle = .default
        p.progress = 0.0
        p.trackTintColor = rgbWithValue(r: 220, g: 220, b: 220, alpha: 0.2)
        p.progressTintColor = .lightGray
        p.layer.cornerRadius = 2
        return p
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, isShow: Bool, star: MusicStar) {
        self.init(frame: frame)
        self.star = star
        SyMusicPlayerManager.getSharedInstance().delegate = self
        
        self.addNotification()
        
        self.layer.backgroundColor = UIColor.darkGray.cgColor
        self.layer.shadowColor = UIColor.white.cgColor //阴影背景
        self.layer.shadowOpacity = 0.08
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: self.frame.size.height + 2))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height + 2))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        self.layer.shadowPath = path.cgPath
        
        self.layer.cornerRadius = 2
        self.backgroundColor = .clear//themeColor()
     
        [self.playerShowViewCloseBtn,self.playerShowViewHeaderImage,self.playerShowViewTitleLab,self.playerShowViewPlayBtn,self.playerShowViewProgress].forEach { view in
            self.addSubview(view)
        }
        self.playerShowViewCloseBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(15)
            make.width.height.equalTo(20)
        }
        
        /*self.playerShowViewHeaderImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40)
            make.top.equalToSuperview().offset(5)
            make.width.height.equalTo(40)
        }*/
        
        self.playerShowViewTitleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(90)
            make.top.equalToSuperview().offset(5)
            make.width.equalTo(self.frame.size.width - 90 - 55)
            make.height.equalTo(40)
        }
        
        self.playerShowViewPlayBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.frame.size.width - 50)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
        }
        
        self.playerShowViewProgress.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(50 - 2)
            make.width.equalTo(self.frame.size.width)
            make.height.equalTo(3)
        }
        self.startTimer()
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        self.pauseTimer()
        if !SyMusicPlayerManager.getSharedInstance().isPlay {
            SyMusicPlayerManager.getSharedInstance().play()
        }
        let vc = SyMusicPlayVC()
        vc.star = self.star
//        vc.musicItem = SyMusicPlayerManager.getSharedInstance().musicItem
        vc.modalPresentationStyle = .fullScreen
        currentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func btnAction(sender: UIButton) {
        switch sender.tag {
        case 0:
            self.removeNotification()
            
            UIView.animate(withDuration: 1, animations: {
                self.stopTimer()
                SyMusicPlayerManager.getSharedInstance().stop()
                //销毁音频播放
                SyMusicPlayerManager.avPlayerDestroy()
                userDefaultsSetValue(value: "0", key: voicePlayKey)
                self.alpha = 0
                //去除远程控制
                UIApplication.shared.endReceivingRemoteControlEvents()
            }, completion: { (isCompletion) in
                self.removeFromSuperview()
            })
        case 1:
            if SyMusicPlayerManager.getSharedInstance().isPlay {
                self.pauseTimer()
                self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "play.circle"), for: .normal)
                SyMusicPlayerManager.getSharedInstance().player.pause()
                SyMusicPlayerManager.getSharedInstance().isPlay = false
            }else{
                self.goOnTimer()
                self.playerShowViewPlayBtn.setBackgroundImage(sfImage(name: "pause.circle"), for: .normal)
                SyMusicPlayerManager.getSharedInstance().play()
            }
        default:
            break
        }
    }
    
    //MARK: - action
    @objc fileprivate func timerAction() {
        if SyMusicPlayerManager.getSharedInstance().isPlay {
//            SyPrint("底部viewShow-->>")
            let endAngle = CGAffineTransform(rotationAngle: self.angle * CGFloat((Double.pi / 180.0)))
            UIView.animate(withDuration: 0.05, delay: 0, options: .curveLinear, animations: {
                self.playerShowViewHeaderImage.transform = endAngle
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
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(playBarChangePlayStateWith(notif:)), name: NSNotification.Name(rawValue: SyMusicPlayerManagerState), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startTimer), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    fileprivate func removeNotification() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
