//
//  SyMusicPlayVC.swift
//  SyMusic
//
//  Created by sxm on 2020/5/18.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit
import MediaPlayer

extension SyMusicPlayVC: SyAudioPlayerViewDelegate {
    //上一曲
    func preMusicActionFunc() {
        if SyMusicPlayerManager.getSharedInstance().playType == SyMusicPlayerManagerType.PlayTypeLine || SyMusicPlayerManager.getSharedInstance().playType == SyMusicPlayerManagerType.PlayTypeSpecial {
            let index = SyMusicPlayerManager.getSharedInstance().currentIndex - 1
            if index < 0 {
                self.view.makeToast(strCommon(key: "sy_first_song_title"))
                return
            }
            SyMusicPlayerManager.getSharedInstance().changeTheMusicByIndex(index: index)
            self.changePlay()
        }
    }
    
    //下一曲
    func nextMusicActionFunc() {
        if SyMusicPlayerManager.getSharedInstance().playType == SyMusicPlayerManagerType.PlayTypeLine || SyMusicPlayerManager.getSharedInstance().playType == SyMusicPlayerManagerType.PlayTypeSpecial {
            let index = SyMusicPlayerManager.getSharedInstance().currentIndex + 1
            let count = SyMusicPlayerManager.getSharedInstance().musicArray.count
            if index >= count {
                self.view.makeToast(strCommon(key: "sy_last_song_title"))
                return
            }
            SyMusicPlayerManager.getSharedInstance().changeTheMusicByIndex(index: index)
            self.changePlay()
        }
    }
    
    func playListActionFunc() {
        let frame = CGRect.init(x: 0, y: 0, width: screenWidth(), height: screenHeight())
        let listView = SyChooseListView(frame: frame, dataSource: SyMusicPlayerManager.getSharedInstance().musicArray)
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
    }
    
    //切换歌曲的时候（上/下一首）
    func changePlay() {
        self.title = SyMusicPlayerManager.getSharedInstance().musicItem?.name
        SyMusicPlayerManager.getSharedInstance().pause()
        self.playView.indicator.startAnimating()
    }
}

class SyMusicPlayVC: SyBaseVC {
    var musicItem: SyMusicsItem?
    var categoryId: String?
    public var star: MusicStar!
    private var showMV: String?
    
    lazy var bgImageView: UIImageView = {
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth(), height: screenHeight()))
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        v.clipsToBounds = true
        v.alpha = 0.9 //值越大视频越模糊不清
        v.image = UIImage.init(named: SyMusicPlayerManager.getSharedInstance().musicItem?.singerIcon ?? "item_headphone_icon")
        //初始化一个基于模糊效果的视觉效果视图
        let blur = UIBlurEffect(style: .systemChromeMaterialDark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = v.frame
        blurView.layer.masksToBounds = true
        v.addSubview(blurView)
        return v
    }()
    
    lazy var playView: SyAudioPlayerView = {
        let view = SyAudioPlayerView(frame: CGRect(x: 0, y: 0, width: screenWidth(), height: screenHeight()), vc: self)
        view.backgroundColor = .clear
        view.delegate = self
        return view
    }()
    
    public lazy var avplayer: AVPlayerLayer = {
        let urlStr = Bundle.main.path(forResource: self.showMV, ofType: "MOV")!
        let videoUrl = URL(fileURLWithPath: urlStr)
        let layer = AVPlayerLayer(player: AVPlayer(url: videoUrl))
        layer.videoGravity = .resizeAspectFill
        layer.frame = self.bgImageView.bounds
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
                userDefaultsSetValue(value: "0", key: voicePlayKey())
                view.removeFromSuperview()
            }
        }
        
        let v = SyMusicPlayerShowView(frame: CGRect(x: 2, y: screenHeight(), width: screenWidth() - 4, height: 50), isShow: true, categoryId: self.categoryId,star: self.star)
        UIView.animate(withDuration: 0.5, animations: {
            v.playerShowViewHeaderImage.image = UIImage(named: self.musicItem?.icon ?? "")
            v.frame.origin.y = currentViewController()?.navigationController?.viewControllers.count == 1 ? (screenHeight() - (isIphoneX() ? 135 : 100)) : screenHeight()
            userDefaultsSetValue(value: "1", key: voicePlayKey())
        }, completion: { (isCompletion) in
            UIApplication.shared.keyWindow?.addSubview(v)
        })
        self.removeNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isBackBar = true
        self.title = self.musicItem?.name
        self.showMV = self.star.rawValue
        self.view.layer.addSublayer(self.avplayer)
        self.view.addSubview(self.bgImageView)
        self.view.addSubview(self.playView)
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
    
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notif:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avplayer.player?.currentItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playBarChangePlayStateWith(notif:)), name: NSNotification.Name(rawValue: SyMusicPlayerManagerState), object: nil)
    }
    
    @objc
    func playBarChangePlayStateWith(notif : Notification){
        //        let url = notif.userInfo?[CurrentPlayUrl]
        if let type = notif.userInfo?[PlayType] as? SyMusicPlayerManagerType,type != .PlayTypeLine {
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
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SyMusicPlayerManagerState), object: nil)
    }
}
