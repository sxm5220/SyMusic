//
//  SyMusicPlayVC.swift
//  SyMusic
//
//  Created by sxm on 2020/5/18.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit
import MediaPlayer

extension SyMusicPlayVC: SyMusicPlayerManagerDelegate {
    
    func updateProgressWith(progress: Float, currentTime: TimeInterval) {
        self.playView.progressView.progress = CGFloat(progress)
        self.playView.endTimerLab.text = SyMusicPlayerManager.getSharedInstance().totalTime
        self.playView.startTimerLab.text = SyMusicPlayerManager.getSharedInstance().currentTime
        self.title = SyMusicPlayerManager.getSharedInstance().musicItem?.musicName
        if progress > 0 && self.playView.indicator.isAnimating{
            self.playView.indicator.stopAnimating()
        }
        
        //背景视频控制播放
        if self.avplayer.player?.timeControlStatus.rawValue == AVPlayer.TimeControlStatus.paused.rawValue && SyMusicPlayerManager.getSharedInstance().isPlay {
            self.avplayer.player?.play()
        }
        let image = SyMusicPlayerManager.getSharedInstance().albumItem?.albumImage ?? ""
        self.bgImageView.image = UIImage(named: image)
        self.playView.centerImageView.image = self.bgImageView.image
    }
    
    func changeMusicToIndex(index: Int) {
        let image = SyMusicPlayerManager.getSharedInstance().albumItem?.albumImage ?? ""
        self.bgImageView.image = UIImage(named: image)
        self.playView.centerImageView.image = self.bgImageView.image
        let musicName = SyMusicPlayerManager.getSharedInstance().musicItem?.musicName ?? ""
        self.playView.lrcVC.lrcMs = SyMusicPlayerManager.getSharedInstance().getLrcMs(musicName) //SyMusicPlayerManager.getSharedInstance().getLrcMs(SyMusicPlayerManager.getSharedInstance().musicItem?.lrcname)
    }
    
    func updateBufferProgress(progress: Float) {
        self.playView.endTimerLab.text = SyMusicPlayerManager.getSharedInstance().totalTime
        self.playView.startTimerLab.text = SyMusicPlayerManager.getSharedInstance().currentTime
        let musicName = SyMusicPlayerManager.getSharedInstance().musicItem?.musicName  ?? ""
        self.playView.lrcVC.lrcMs = SyMusicPlayerManager.getSharedInstance().getLrcMs(musicName)
        //self.lrcVC.lrcMs = SyMusicPlayerManager.getSharedInstance().getLrcMs(SyMusicPlayerManager.getSharedInstance().musicItem?.lrcname)
    }
    
}


extension SyMusicPlayVC: SyAudioPlayerViewDelegate {
    //上一曲
    func preMusicActionFunc() {
        let index = SyMusicPlayerManager.getSharedInstance().currentIndex - 1
        if index < 0 {
            self.view.makeToast(strCommon(key: "sy_first_song_title"))
            return
        }
        SyMusicPlayerManager.getSharedInstance().changeTheMusicByIndex(index: index)
        self.changePlay()
    }
    
    //下一曲
    func nextMusicActionFunc() {
        let index = SyMusicPlayerManager.getSharedInstance().currentIndex + 1
        let count = SyMusicPlayerManager.getSharedInstance().musicArray.count
        if index >= count {
            self.view.makeToast(strCommon(key: "sy_last_song_title"))
            return
        }
        SyMusicPlayerManager.getSharedInstance().changeTheMusicByIndex(index: index)
        self.changePlay()
    }
    
    func playListActionFunc() {
        let listView = SyChooseListView(dataSource: SyMusicPlayerManager.getSharedInstance().musicArray)
        listView.myClosure = { (id: String) -> Void in
            for i in 0..<SyMusicPlayerManager.getSharedInstance().musicArray.count {
                let model: SyMusicsItem = SyMusicPlayerManager.getSharedInstance().musicArray[i]
                if id == model.id {
                    SyMusicPlayerManager.getSharedInstance().playTheLine(index: i, isImmediately: true)
                    self.changePlay()
                }
            }
        }
        self.view.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.view.snp.height)
            make.width.equalTo(self.view.snp.width)
        }
    }
    
    //切换歌曲的时候（上/下一首）
    func changePlay() {
        self.title = SyMusicPlayerManager.getSharedInstance().musicItem?.musicName
        SyMusicPlayerManager.getSharedInstance().pause()
        self.playView.indicator.startAnimating()
    }
}

class SyMusicPlayVC: SyBaseVC {
    var musicName: String?
    public var star: MusicStar!
    private var showMV: String?
    
    lazy var bgImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        v.clipsToBounds = true
        v.alpha = 0.9 //值越大视频越模糊不清
        //v.image = UIImage.init(named: SyMusicPlayerManager.getSharedInstance().musicImageName ?? "item_headphone_icon")//UIImage.init(named: SyMusicPlayerManager.getSharedInstance().musicItem?.singerIcon ?? "item_headphone_icon")
        return v
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        //初始化一个基于模糊效果的视觉效果视图
        let blur = UIBlurEffect(style: .systemChromeMaterialDark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.layer.masksToBounds = true
        return blurView
    }()
    
    lazy var playView: SyAudioPlayerView = {
        let view = SyAudioPlayerView(vc: self)
        view.backgroundColor = .clear
        view.delegate = self
        return view
    }()
    
    public lazy var avplayer: AVPlayerLayer = {
        let urlStr = Bundle.main.path(forResource: self.showMV, ofType: "MOV")!
        let videoUrl = URL(fileURLWithPath: urlStr)
        let layer = AVPlayerLayer(player: AVPlayer(url: videoUrl))
        layer.videoGravity = .resizeAspectFill
        layer.frame = self.view.bounds
        layer.player?.actionAtItemEnd = .none
        return layer
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let windows: [UIView] = UIApplication.shared.keyWindow?.subviews else { return }
        windows.forEach { (view) in
            if view.classForCoder == SyMusicPlayerShowView().classForCoder{
                userDefaultsSetValue(value: "0", key: voicePlayKey)
                view.removeFromSuperview()
            }
        }
        
        let v = SyMusicPlayerShowView(frame: CGRect(x: 2, y: screenHeight, width: screenWidth - 4, height: 50), isShow: true,star: self.star)
        UIView.animate(withDuration: 0.5, animations: {
            v.frame.origin.y = currentViewController()?.navigationController?.viewControllers.count == 1 ? (screenHeight - 135) : screenHeight
            userDefaultsSetValue(value: "1", key: voicePlayKey)
        }, completion: { (isCompletion) in
            UIApplication.shared.keyWindow?.addSubview(v)
        })
        self.removeNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isBackBar = true
        self.title = SyMusicPlayerManager.getSharedInstance().musicItem?.musicName
        
        SyMusicPlayerManager.getSharedInstance().delegate = self
        
        self.showMV = self.star.rawValue
        self.view.layer.addSublayer(self.avplayer)
        [self.bgImageView,self.playView].forEach { view in
            self.view.addSubview(view)
        }
        self.bgImageView.addSubview(self.blurView)
        
        self.bgImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.view.snp.height)
            make.width.equalTo(self.view.snp.width)
        }
        
        self.playView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.view.snp.height)
            make.width.equalTo(self.view.snp.width)
        }
        
        self.blurView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.view.snp.height)
            make.width.equalTo(self.view.snp.width)
        }
    }
    
    override func viewWillLayoutSubviews() {//尺寸类的放在这里进行调整，以获取到最终的正确尺寸
        super.viewWillLayoutSubviews()
        self.playView.lrcVC.tableView.frame = self.playView.lrcScrollView.bounds//歌词视图大小调整
        self.playView.lrcVC.tableView.frame.origin.x = self.playView.lrcScrollView.frame.size.width//默认放在最右边，滚动时出现
        self.playView.lrcScrollView.contentSize = CGSize(width: self.playView.lrcScrollView.frame.size.width * 2, height: 0)//scroll，要实现滚动的前提是要有contentSize，2页的大小
        self.playView.centerImageView.layer.cornerRadius = self.playView.centerImageView.frame.size.width * 0.5//大图片圆形效果
        self.playView.centerImageView.layer.masksToBounds = true
    }
}

extension SyMusicPlayVC {
    
    //进入后台暂停
    @objc func enterBackground() {
        self.playView.waterWaveView.isShow = true
        if SyMusicPlayerManager.getSharedInstance().isPlay {
            self.playView.waterWaveView.pauseFun()
        }
    }
    
    //从后台打开
    @objc func becomeActive() {
        self.playView.waterWaveView.isShow = true
        if SyMusicPlayerManager.getSharedInstance().isPlay {
            self.playView.waterWaveView.reStartFun()
        }
    }
    
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(self, selector:#selector(self.enterBackground),name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.becomeActive),name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notif:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avplayer.player?.currentItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playBarChangePlayStateWith(notif:)), name: NSNotification.Name(rawValue: SyMusicPlayerManagerState), object: nil)
    }
    
    @objc
    func playBarChangePlayStateWith(notif : Notification){
        //        let url = notif.userInfo?[CurrentPlayUrl]
        if let type = notif.userInfo?[PlayType] as? SyMusicPlayerManagerType,type == .PlayTypePay {
            self.playView.progressView.progress = 0.0
            self.playView.playBtn.setBackgroundImage(sfImage(name: "play"), for: .normal)
        }
        guard let state = notif.userInfo?[SyMusicPlayerManagerState] as? AVPlayerPlayState else {return}
        switch state {
        case AVPlayerPlayState.AVPlayerPlayStatePreparing,AVPlayerPlayState.AVPlayerPlayStateBeigin,AVPlayerPlayState.AVPlayerPlayStatePlaying:
            self.playView.playBtn.setBackgroundImage(sfImage(name: "pause"), for: .normal)
        case .AVPlayerPlayStatePause:
            self.playView.playBtn.setBackgroundImage(sfImage(name: "play"), for: .normal)
        case .AVPlayerPlayStateEnd:
            self.playView.endTimerLab.text = "00:00"
            self.playView.playBtn.setBackgroundImage(sfImage(name: "play"), for: .normal)
        case .AVPlayerPlayStateNotPlay:
            self.playView.endTimerLab.text = ""
            self.playView.startTimerLab.text = ""
            self.playView.progressView.progress = 0.0
            self.playView.playBtn.setBackgroundImage(sfImage(name: "play"), for: .normal)
        case .AVPlayerPlayStateBufferEmpty:
            SyPrint("没有缓存了不可以播放.......(2)")
        case .AVPlayerPlayStateBufferToKeepUp:
            SyPrint("有缓存了可以播放了.......(1)")
        case .AVPlayerPlayStateseekToZeroBeforePlay:
            self.playView.progressView.progress = 0.0
        default:
            self.playView.playBtn.setBackgroundImage(sfImage(name: "play"), for: .normal)
        }
    }
    
    @objc
    func playerItemDidReachEnd(notif : Notification){
        guard let p = notif.object as? AVPlayerItem else { return }
        p.seek(to: .zero, completionHandler: nil)
    }
    
    public func removeNotification() {
        //歌词定时器移除
        self.playView.removeLink()
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SyMusicPlayerManagerState), object: nil)
    }
}
