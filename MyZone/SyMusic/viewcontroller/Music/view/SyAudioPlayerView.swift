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
import Toast_Swift
import HGCircularSlider
import MarqueeLabel

public protocol SyAudioPlayerViewDelegate: NSObjectProtocol {
    func preMusicActionFunc()
    func nextMusicActionFunc()
    func playListActionFunc()
}

extension SyAudioPlayerView: UIScrollViewDelegate {
    //滚动到歌词页面（page 2），主页面（page 1）alpha = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {//alpha change
        let radio = 1 - scrollView.contentOffset.x / scrollView.frame.size.width
        self.startTimerLab.alpha = radio
        self.endTimerLab.alpha = radio
        self.progressView.alpha = radio
        self.centerImageView.alpha = radio
        self.lrcLabel.alpha = radio
        self.waterWaveView.alpha = radio
    }
}

class SyAudioPlayerView: UIView {
    
    weak open var delegate: SyAudioPlayerViewDelegate?
    
    var vc: SyMusicPlayVC!
    
    private let playImages = [sfImage(name: "music.note.list"),
                              sfImage(name: "backward.end"),
                              sfImage(name: "pause"),
                              sfImage(name: "forward.end"),
                              sfImage(name: "repeat")]
    var isSingleCycle: Bool = false
    var cycleBtn: UIButton = UIButton()
    var playBtn: UIButton = UIButton()
    private let KWaterWave: CGFloat = screenWidth * 0.5 + 50.0 //水波纹宽度
    private var imgWidth: CGFloat = 0
    
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
    
    //水波动效
    public lazy var waterWaveView: SyWaterWaveView = {
        let view = SyWaterWaveView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    //音频背景图
    lazy var centerImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.frame = CGRect(x: (screenWidth - imgWidth) / 2, y: 160, width: imgWidth, height: imgWidth)
        imgView.clipsToBounds = true
//        imgView.center = self.waterWaveView.center
        imgView.image = #imageLiteral(resourceName: "item_headphone_icon")
        imgView.contentMode = .scaleAspectFill
        imgView.layer.mask = imgView.roundCorner(imageView: imgView)
        //imgView.image = UIImage.init(named: SyMusicPlayerManager.getSharedInstance().musicImageName ?? "item_headphone_icon")
        imgView.layer.removeAnimation(forKey: "rotation")
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = 30
        animation.isRemovedOnCompletion = false
        animation.repeatCount = MAXFLOAT
        imgView.layer.add(animation, forKey: "rotation")
        return imgView
    }()
    
    //播放时间
    lazy var startTimerLab: SyLabel = {
        let lab = SyLabel.init(text: "00:00", textColor: .lightGray, font: UIFont.systemFont(ofSize: 11), textAlignment: .center)
        return lab
    }()
    
    //结束时间
    lazy var endTimerLab: SyLabel = {
        let lab = SyLabel.init(text: "00:00", textColor: .lightGray, font: UIFont.systemFont(ofSize: 11), textAlignment: .center)
        return lab
    }()
    
    //滑动进度条 (由于歌词用UIScrollView 左滑覆盖 所以滑动条不能添加 有时间看看如何添加上......)
   /* private lazy var sliderView: CircularSlider = {
        let v = CircularSlider.init(frame: CGRect(x: 0, y: 0, width: self.centerImageView.bounds.size.width + 50, height: self.centerImageView.bounds.size.width + 50))
        v.center = self.centerImageView.center
        v.diskFillColor = .green
        v.diskColor = .black
        v.trackFillColor = .purple
        v.trackColor = .white
        v.trackShadowColor = .white
        v.thumbRadius = 2
        v.lineWidth = 2
        v.endThumbStrokeHighlightedColor = .purple
        v.endThumbStrokeColor = .purple
        return v
    }()*/
    
    //播放进度条
    lazy var progressView: ZZCircleProgress = {
        let v = ZZCircleProgress()
//        v.center = self.centerImageView.center
        v.pathBackColor = UIColor.init(white: 0.667, alpha: 0.2)//.darkGray
        v.pathFillColor = .white//rgbWithValue(r: 65, g: 44, b: 142, alpha: 1.0)
        v.startAngle = 0
        v.reduceAngle = 180
        v.strokeWidth = 3
        v.pointImage.image = sfImage(name: "circlebadge.fill")
        v.duration = 0.1
        //        v.showPoint = true
        v.progress = 0
        v.showProgressText = false
        v.increaseFromLast = true
        return v
    }()
    
    //歌词
    lazy var lrcVC: SyLrcTVC = {
        let v = SyLrcTVC()
        v.tableView.isUserInteractionEnabled = true
        v.tableView.backgroundColor = .clear
        v.lrcMs = SyMusicPlayerManager.getSharedInstance().getLrcMs(SyMusicPlayerManager.getSharedInstance().musicItem?.musicName)
        return v
    }()
    
    lazy var lrcScrollView: UIScrollView = {
        let v = UIScrollView()
        v.addSubview(self.lrcVC.tableView)//添加歌词控制器的tableview（歌词视图） 到 滚动视图中进行占位
        v.backgroundColor = .clear
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
    
    //主页动态歌词
    lazy var lrcLabel: SyLrcDEffectLabel = {
        let lab = SyLrcDEffectLabel()
        lab.textColor = .lightGray
        lab.textAlignment = .center
        return lab
    }()
    
    //歌词变的定时器
    private var updateLrcLink: CADisplayLink?
    
    func removeLink() {
        updateLrcLink?.invalidate()
        updateLrcLink = nil
    }
    
    @objc
    func updateLrc() {
        var time: TimeInterval = 0
        if let current = SyMusicPlayerManager.getSharedInstance().player.currentItem?.currentTime(){
            time = TimeInterval(CMTimeGetSeconds(current))
        }
        let rowLrcM = SyMusicPlayerManager.getSharedInstance().getCurrentLrcM(time, lrcMs: self.lrcVC.lrcMs)
        let lrcM = rowLrcM.lrcM
        self.lrcLabel.text = lrcM?.lrcContent//更新歌词，固定的单行歌词
        if lrcM != nil {
            self.lrcLabel.radio = CGFloat((time - lrcM!.beginTime) / (lrcM!.endTime - lrcM!.beginTime))
            self.lrcVC.progress = self.lrcLabel.radio//同步更新歌词进度，一行歌词着色进度
            self.lrcVC.scrollRow = rowLrcM.row//流动整屏时用到的位置行
        }
        if UIApplication.shared.applicationState == .background {
            SyMusicPlayerManager.getSharedInstance().setupLockMessage()//更新锁屏界面信息
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imgWidth = screenWidth * 0.5
        
        self.isSingleCycle = userDefaultsForString(forKey: cycleVoiceStateKey) == "1" ? true : false
    }
    
    convenience init(vc: SyMusicPlayVC) {
        self.init(frame: CGRect.zero)
        self.vc = vc
        
        [self.waterWaveView,self.centerImageView,self.lrcLabel,self.lrcScrollView,self.startTimerLab,self.endTimerLab,self.progressView,self.indicator].forEach { view in
            self.addSubview(view)
        }
        
        /*let centerImageViewLeading = (screenWidth - imgWidth) / 2
        let centerImageViewTop = screenHeight / 3 + imgWidth / 2
        self.centerImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(centerImageViewLeading)
            make.top.equalToSuperview().offset(centerImageViewTop)
            make.width.height.equalTo(imgWidth)
        }*/
        
        let waterWaveViewLeading = (screenWidth - KWaterWave) / 2
        let waterWaveViewTop = 135
        self.waterWaveView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(waterWaveViewLeading)
            make.top.equalToSuperview().offset(waterWaveViewTop)
            make.width.height.equalTo(KWaterWave)
        }
        
        let lrcLabelTop = screenHeight / 2 + 80
        self.lrcLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(lrcLabelTop)
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(20)
        }
         
        let startTimerLableading = (screenWidth - imgWidth) / 2 - 50
        let startTimerLabTop = screenHeight / 3 - 50
        self.startTimerLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(startTimerLableading)
            make.top.equalToSuperview().offset(startTimerLabTop)
            make.width.equalTo(50)
            make.height.equalTo(20)
        }
        
        let endTimerLableading = (screenWidth - imgWidth) / 2 - 50
        self.endTimerLab.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-endTimerLableading)
            make.top.equalToSuperview().offset(startTimerLabTop)
            make.width.equalTo(50)
            make.height.equalTo(20)
        }
        
        let progressViewTop = startTimerLabTop - imgWidth / 2 + 5
        let progressViewLeading = (screenWidth - imgWidth) / 2 - 25
        self.progressView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(progressViewLeading)
            make.top.equalToSuperview().offset(progressViewTop)
            make.width.equalTo(imgWidth + 50)
            make.height.equalTo(imgWidth + 55)
        }
        
        self.lrcScrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(lrcLabelTop + 30)
        }
        
        let indicatorLeading = (screenWidth - 60) / 2
        self.indicator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(indicatorLeading)
            make.top.equalToSuperview().offset(lrcLabelTop + 40)
            make.height.width.equalTo(60)
        }
        
        let kw: CGFloat = (screenWidth - 30*5) / 6
        let KSettingBtnMargin: CGFloat = 30.0
        for i in 0..<self.playImages.count {
            var btnValue = KSettingBtnMargin
            var rectyValue = lrcLabelTop + 50.0
            if i == 0 || i == (self.playImages.count - 1){
                btnValue -= 10
                rectyValue += 5
            }else if i == 2 {
                btnValue += 10
                rectyValue -= 5
            }
            let btn = buttonWithImageFrame(imageName: self.playImages[i], tag: i, target: self, action: #selector(btnAction(sender:)))
            btn.frame = CGRect(x: kw + (KSettingBtnMargin + kw)*CGFloat(i) + (i == 2 ? -5 : 0), y: rectyValue, width: btnValue, height: btnValue)
            self.addSubview(btn)
            if i == 2 {
                self.indicator.center = btn.center
                self.playBtn = btn
            }else if i == 4 {
                self.cycleBtn = btn
                if self.isSingleCycle {
                    self.cycleBtn.setBackgroundImage(sfImage(name: "repeat.1"), for: .normal)
                }else{
                    self.cycleBtn.setBackgroundImage(sfImage(name: "repeat"), for: .normal)
                }
            }
        }
        
        self.indicator.startAnimating()
        
        self.updateLrcLink = CADisplayLink(target: self, selector: #selector(self.updateLrc))
        self.updateLrcLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    /*
    @objc func sliderTouchUp(sender: UISlider) {
        //跳到指定时间点播放
        SyMusicPlayerManager.getSharedInstance().musicSeekToTime(time: Float(self.progressView.progress))
    }*/
    
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
            if SyMusicPlayerManager.getSharedInstance().musicItem?.musicName.trimmingCharactersCount ?? 0 > 0 {
                if self.indicator.isAnimating {
                    return
                }
                self.playOrPauseFunc()
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
    
    func playOrPauseFunc() {
        self.updateLrcLink?.isPaused = SyMusicPlayerManager.getSharedInstance().isPlay
        SyMusicPlayerManager.getSharedInstance().isPlay == true ? SyMusicPlayerManager.getSharedInstance().pause() : SyMusicPlayerManager.getSharedInstance().play()
        SyMusicPlayerManager.getSharedInstance().isPlay == true ? self.centerImageView.layer.resumeAnimate() : self.centerImageView.layer.pauseAnimate()
        SyMusicPlayerManager.getSharedInstance().isPlay == true ? self.vc.avplayer.player?.play() : self.vc.avplayer.player?.pause()
        SyMusicPlayerManager.getSharedInstance().isPlay == true ? self.waterWaveView.reStartFun() : self.waterWaveView.pauseFun()
    }
    
    func cycleFunc() {
        self.isSingleCycle = !self.isSingleCycle
        if self.isSingleCycle {
            self.cycleBtn.setBackgroundImage(sfImage(name: "repeat.1"), for: .normal)
            userDefaultsSetValue(value: "1", key: cycleVoiceStateKey)
            self.makeToast(strCommon(key: "sy_single_cycle_title"))
        }else{
            self.cycleBtn.setBackgroundImage(sfImage(name: "repeat"), for: .normal)
            userDefaultsSetValue(value: "0", key: cycleVoiceStateKey)
            self.makeToast(strCommon(key: "sy_list_cycle_title"))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
