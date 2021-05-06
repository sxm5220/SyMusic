//
//  SyAudioPlayerView.swift
//  SyMusic
//
//  Created by sxm on 2020/6/20.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import MediaPlayer
import ZZCircleProgress

extension SyAudioPlayerView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {//alpha change
        let radio = 1 - scrollView.contentOffset.x / scrollView.frame.size.width
        self.startTimerLab.alpha = radio
        self.endTimerLab.alpha = radio
        self.sliderView.alpha = radio
        self.centerImageView.alpha = radio
        self.lrcLabel.alpha = radio
    }
}

extension SyAudioPlayerView {
    @objc
    func playBarChangePlayStateWith(notif : Notification){
        //        let url = notif.userInfo?[CurrentPlayUrl]
        if let type = notif.userInfo?[PlayType] as? SyAVPlayerType,type != .PlayTypeLine {
            self.sliderView.progress = 0.0
            self.playBtn.setBackgroundImage(#imageLiteral(resourceName: "item_audio_player_star_icon"), for: .normal)
        }
        guard let state = notif.userInfo?[SyAVPlayerState] as? AVPlayerPlayState else {return}
        switch state {
        case AVPlayerPlayState.AVPlayerPlayStatePreparing,AVPlayerPlayState.AVPlayerPlayStateBeigin,AVPlayerPlayState.AVPlayerPlayStatePlaying:
            self.playBtn.setBackgroundImage(#imageLiteral(resourceName: "item_audio_player_play_icon"), for: .normal)
        case .AVPlayerPlayStatePause:
            self.playBtn.setBackgroundImage(#imageLiteral(resourceName: "item_audio_player_star_icon"), for: .normal)
        case .AVPlayerPlayStateEnd:
            self.endTimerLab.text = "00:00"
            self.playBtn.setBackgroundImage(#imageLiteral(resourceName: "item_audio_player_star_icon"), for: .normal)
        case .AVPlayerPlayStateNotPlay:
            self.endTimerLab.text = ""
            self.startTimerLab.text = ""
            self.sliderView.progress = 0.0
            self.playBtn.setBackgroundImage(#imageLiteral(resourceName: "item_audio_player_star_icon"), for: .normal)
        case .AVPlayerPlayStateBufferEmpty:
            SyPrint("没有缓存了不可以播放.......(2)")
        case .AVPlayerPlayStateBufferToKeepUp:
            SyPrint("有缓存了可以播放了.......(1)")
        case .AVPlayerPlayStateseekToZeroBeforePlay:
            self.sliderView.progress = 0.0
        default:
            self.playBtn.setBackgroundImage(#imageLiteral(resourceName: "item_audio_player_star_icon"), for: .normal)
        }
    }
}

public protocol SyAudioPlayerViewDelegate: NSObjectProtocol {
    func preMusicActionFunc()
    func nextMusicActionFunc()
    func playListActionFunc()
}

class SyAudioPlayerView: UIView, SyAVPlayerDelegate {
    
    weak open var delegate: SyAudioPlayerViewDelegate?
    
    func updateProgressWith(progress: Float) {
        self.sliderView.progress = CGFloat(progress)
        self.endTimerLab.text = SyAVPlayer.getSharedInstance().totalTime
        self.startTimerLab.text = SyAVPlayer.getSharedInstance().currentTime
        self.vc.title = SyAVPlayer.getSharedInstance().model?.name
        self.vc.bgImageView.image = UIImage.init(named: SyAVPlayer.getSharedInstance().model?.singerIcon ?? "")
        self.centerImageView.image = self.vc.bgImageView.image
        if progress > 0 && self.indicator.isAnimating {
            self.indicator.stopAnimating()
        }
    }
    
    func changeMusicToIndex(index: Int) {
        self.vc.bgImageView.image = UIImage.init(named: SyAVPlayer.getSharedInstance().model?.singerIcon ?? "")
        self.centerImageView.image = self.vc.bgImageView.image
        self.lrcVC.lrcMs = SyAVPlayer.getSharedInstance().getLrcMs(SyAVPlayer.getSharedInstance().model?.lrcname)
    }
    
    func updateBufferProgress(progress: Float) {
        self.endTimerLab.text = SyAVPlayer.getSharedInstance().totalTime
        self.startTimerLab.text = SyAVPlayer.getSharedInstance().currentTime
        self.lrcVC.lrcMs = SyAVPlayer.getSharedInstance().getLrcMs(SyAVPlayer.getSharedInstance().model?.lrcname)
    }
    
    var vc: SyMusicPlayVC!
    fileprivate static let kMargin: CGFloat = 100.0
    fileprivate let KSettingBtnMargin: CGFloat = 30.0
    fileprivate let kValue = screenWidth() - kMargin * 2
    fileprivate let playImages = [#imageLiteral(resourceName: "item_menu_icon"),#imageLiteral(resourceName: "item_prev_song_icon"),#imageLiteral(resourceName: "item_audio_player_play_icon"),#imageLiteral(resourceName: "item_next_song_icon"),#imageLiteral(resourceName: "item_loop_all_icon")]
    fileprivate let kw = (screenWidth() - 30*5) / 6
    var isSingleCycle: Bool = false
    var cycleBtn: UIButton = UIButton()
    var playBtn: UIButton = UIButton()
    
    fileprivate let imgWidth: CGFloat = screenWidth() * 0.5
    
    lazy var context: CIContext = {
        return CIContext(options: nil)
    }()
    
    //加载指示
    lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(style: .large)
        indicator.backgroundColor = .clear
        indicator.color = .darkGray
        return indicator
    }()
    
    //音频背景图
    lazy var centerImageView: UIImageView = {
        let imgView = UIImageView.init(frame: CGRect.init(x: (screenWidth() - imgWidth) / 2, y: (screenHeight() - imgWidth) / 2 - 150, width: imgWidth, height: imgWidth))
        imgView.clipsToBounds = true
        imgView.image = #imageLiteral(resourceName: "item_headphone_icon")
        imgView.contentMode = .scaleAspectFill
        imgView.layer.mask = imgView.roundCorner(imageView: imgView)
        return imgView
    }()
    
    //播放时间
    lazy var startTimerLab: SyLabel = {
        let lab = SyLabel.init(frame: CGRect.init(x: self.centerImageView.frame.origin.x - 50, y: 0, width: 50, height: 20), text: "00:00", textColor: .lightGray, font: UIFont.systemFont(ofSize: 11), textAlignment: .center)
        lab.center.y = self.centerImageView.center.y - 15
        return lab
    }()
    
    //结束时间
    lazy var endTimerLab: SyLabel = {
        let lab = SyLabel.init(frame: CGRect.init(x: self.centerImageView.frame.maxX, y: startTimerLab.frame.origin.y, width: startTimerLab.bounds.size.width, height: 20), text: "00:00", textColor: .lightGray, font: UIFont.systemFont(ofSize: 11), textAlignment: .center)
        lab.center.y = self.startTimerLab.center.y
        return lab
    }()
    
    //播放进度条
    /*lazy var sliderView: UISlider = {
     let sliderView = UISlider.init(frame: CGRect.init(x: startTimerLab.frame.maxX + 5, y: screenHeight() - 280, width: screenWidth() - (startTimerLab.frame.maxX + 5*2 + (screenWidth() - endTimerLab.frame.minX)), height: 20))
     sliderView.setThumbImage(#imageLiteral(resourceName: "item_music_slider_circle_icon"), for: .highlighted)
     sliderView.setThumbImage(#imageLiteral(resourceName: "item_music_slider_circle_icon"), for: .normal)
     sliderView.minimumValue = 0
     sliderView.maximumValue = 1
     sliderView.minimumTrackTintColor = UIColor.black
     sliderView.maximumTrackTintColor = UIColor.lightGray
     sliderView.addTarget(self, action: #selector(sliderTouchUp(sender:)), for: .touchUpInside)
     return sliderView
     }()*/
    lazy var sliderView: ZZCircleProgress = {
        let v = ZZCircleProgress.init(frame: CGRect(x: 0, y: 0, width: self.centerImageView.bounds.size.width + 50, height: self.centerImageView.bounds.size.width + 50))
        v.center = self.centerImageView.center
        v.pathBackColor = .darkGray
        v.pathFillColor = .white//rgbWithValue(r: 65, g: 44, b: 142, alpha: 1.0)
        v.startAngle = 0
        v.reduceAngle = 180
        v.strokeWidth = 3
        v.pointImage.image = #imageLiteral(resourceName: "item_music_slider_circle_icon")
        v.duration = 0.1
        //        v.showPoint = true
        v.progress = 0
        v.showProgressText = false
        v.increaseFromLast = true
        return v
    }()
    
    lazy var lrcVC: SyLrcTVC = {
        let lrcVC = SyLrcTVC()
        lrcVC.tableView.isUserInteractionEnabled = true
        lrcVC.tableView.backgroundColor = .clear
        return lrcVC
    }()
    
    lazy var lrcScrollView: UIScrollView = {
        let v = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.sliderView.frame.maxY + 150))
        v.addSubview(self.lrcVC.tableView)//添加歌词控制器的tableview（歌词视图） 到 滚动视图中进行占位
        v.bounces = true
        v.bouncesZoom = true
        v.isUserInteractionEnabled = true
        v.delaysContentTouches = true
        v.canCancelContentTouches = true
        v.isMultipleTouchEnabled = true
        v.delegate = self//滚动代理用UIScrollViewDelegate〈scrollViewDidScroll〉
        v.isPagingEnabled = true//滚动scrollview时分页
        v.showsHorizontalScrollIndicator = false//去掉滚动条
        return v
    }()
    
    //歌词
    lazy var lrcLabel: SyLrcLabel = {
        let lab = SyLrcLabel(frame: CGRect(x: 20, y: self.sliderView.frame.maxY + 100, width: self.bounds.size.width - 20*2, height: 20))
        lab.textColor = .lightGray
        lab.textAlignment = .center
        return lab
    }()
    
    //歌词变的定时器
    fileprivate var updateLrcLink: CADisplayLink?
    
    func addLink() {
        updateLrcLink = CADisplayLink(target: self, selector: #selector(self.updateLrc))
        updateLrcLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    func removeLink() {
        updateLrcLink?.invalidate()
        updateLrcLink = nil
    }
    
    @objc
    func updateLrc() {
        var time: TimeInterval = 0
        if let current = SyAVPlayer.getSharedInstance().player.currentItem?.currentTime(){
            time = TimeInterval(CMTimeGetSeconds(current))
        }
        let rowLrcM = SyAVPlayer.getSharedInstance().getCurrentLrcM(time, lrcMs: self.lrcVC.lrcMs)
        let lrcM = rowLrcM.lrcM
        lrcLabel.text = lrcM?.lrcContent//更新歌词，固定的单行歌词
        if lrcM != nil {
            lrcLabel.radio = CGFloat((time - lrcM!.beginTime) / (lrcM!.endTime - lrcM!.beginTime))
            self.lrcVC.progress = lrcLabel.radio//同步更新歌词进度，一行歌词着色进度
            self.lrcVC.scrollRow = rowLrcM.row//流动整屏时用到的位置行
        }
        if UIApplication.shared.applicationState == .background {
            SyAVPlayer.getSharedInstance().setupLockMessage()//更新锁屏界面信息
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addNotification()
    }
    
    convenience init(frame: CGRect, vc: SyMusicPlayVC) {
        self.init(frame: frame)
        self.vc = vc
        
        self.isSingleCycle = userDefaultsForString(forKey: cycleVoiceStateKey()) == "1" ? true : false
        
        self.centerImageView.image = UIImage.init(named: SyAVPlayer.getSharedInstance().model?.singerIcon ?? "item_headphone_icon")
        self.addSubview(centerImageView)
        self.addSubview(lrcLabel)
        self.addSubview(lrcScrollView)
        
        for i in 0..<playImages.count {
            var btnValue = KSettingBtnMargin
            var rectyValue = self.sliderView.frame.maxY + 170
            if i == 0 || i == (playImages.count - 1){
                btnValue -= 10
                rectyValue += 5
            }else if i == 2 {
                btnValue += 20
                rectyValue -= 10
            }
            let btn = buttonWithImageFrame(frame: CGRect(x: kw + (KSettingBtnMargin + kw)*CGFloat(i) + (i == 2 ? -10 : 0), y: rectyValue, width: btnValue, height: btnValue), imageName: playImages[i], tag: i, target: self, action: #selector(btnAction(sender:)))
            self.addSubview(btn)
            if i == 2 {
                indicator.center = btn.center
                self.playBtn = btn
            }else if i == 4 {
                self.cycleBtn = btn
                if self.isSingleCycle {
                    self.cycleBtn.setBackgroundImage(#imageLiteral(resourceName: "item_loop_single_icon"), for: .normal)
                }else{
                    self.cycleBtn.setBackgroundImage(#imageLiteral(resourceName: "item_loop_all_icon"), for: .normal)
                }
            }
        }
        self.addSubview(startTimerLab)
        self.addSubview(endTimerLab)
        self.addSubview(sliderView)
        self.addSubview(indicator)
        self.indicator.startAnimating()
        SyAVPlayer.getSharedInstance().delegate = self
        self.addLink()
        //大圆图播放旋转动画
        self.centerImageView.layer.removeAnimation(forKey: "rotation")
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = 30
        animation.isRemovedOnCompletion = false
        animation.repeatCount = MAXFLOAT
        self.centerImageView.layer.add(animation, forKey: "rotation")
        
        self.lrcVC.lrcMs = SyAVPlayer.getSharedInstance().getLrcMs(SyAVPlayer.getSharedInstance().model?.lrcname)
    }
    
    @objc func sliderTouchUp(sender: UISlider) {
        //跳到指定时间点播放
        SyAVPlayer.getSharedInstance().musicSeekToTime(time: Float(self.sliderView.progress))
    }
    
    @objc
    func btnAction(sender: UIButton) {
        switch sender.tag {
        case 0: //播放列表
            if let delegate = self.delegate {
                delegate.playListActionFunc()
            }
        case 1: //上一曲
            if let delegate = self.delegate {
                delegate.preMusicActionFunc()
            }
        case 2: //播放暂停
            if SyAVPlayer.getSharedInstance().model?.name.trimmingCharactersCount ?? 0 > 0 {
                if self.indicator.isAnimating {
                    return
                }
                self.playFunc()
            }
        case 3: //下一曲
            if let delegate = self.delegate {
                delegate.nextMusicActionFunc()
            }
        case 4: //循环
            self.cycleFunc()
        default:
            break
        }
    }
    
    func playFunc() {
        self.updateLrcLink?.isPaused = SyAVPlayer.getSharedInstance().isPlay
        SyAVPlayer.getSharedInstance().isPlay == true ? SyAVPlayer.getSharedInstance().pause() : SyAVPlayer.getSharedInstance().play()
        SyAVPlayer.getSharedInstance().isPlay == true ? self.centerImageView.layer.resumeAnimate() : self.centerImageView.layer.pauseAnimate()
    }
    
    func cycleFunc() {
        self.isSingleCycle = !self.isSingleCycle
        if self.isSingleCycle {
            self.cycleBtn.setBackgroundImage(#imageLiteral(resourceName: "item_loop_single_icon"), for: .normal)
            userDefaultsSetValue(value: "1", key: cycleVoiceStateKey())
            progressHUDShowWarningWithStatus(status: strCommon(key: "sy_single_cycle_title"))
        }else{
            self.cycleBtn.setBackgroundImage(#imageLiteral(resourceName: "item_loop_all_icon"), for: .normal)
            userDefaultsSetValue(value: "0", key: cycleVoiceStateKey())
            progressHUDShowWarningWithStatus(status: strCommon(key: "sy_list_cycle_title"))
        }
    }
    
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(playBarChangePlayStateWith(notif:)), name: NSNotification.Name(rawValue: SyAVPlayerState), object: nil)
    }
    
    fileprivate func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SyAVPlayerState), object: nil)
    }
    
    deinit {
        self.removeNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
