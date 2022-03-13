//
//  SyMusicPlayerManager.swift
//  wwsq
//
//  Created by 宋晓明 on 2019/10/22.
//  Copyright © 2019 wwsq. All rights reserved.
//

import Foundation
import MediaPlayer

public enum AVPlayerPlayState {
    case AVPlayerPlayStatePreparing     // 准备播放
    case AVPlayerPlayStateBeigin        // 开始播放
    case AVPlayerPlayStatePlaying       // 正在播放
    case AVPlayerPlayStatePause         // 播放暂停
    case AVPlayerPlayStateEnd           // 播放结束
    case AVPlayerPlayStateBufferEmpty   // 没有缓存的数据供播放了
    case AVPlayerPlayStateBufferToKeepUp  //有缓存的数据可以供播放
    case AVPlayerPlayStateseekToZeroBeforePlay
    case AVPlayerPlayStateNotPlay       // 不能播放
    case AVPlayerPlayStateNotKnow       // 未知情况
}

public enum SyMusicPlayerManagerType {
    case PlayTypeLine    //景点，线路
    case PlayTypeSpecial //专题播放
    case PlayTypeTry     //试听
    case PlayTypeAnswer  //回答问题
    case PlayTypeDefult  //其他
}

protocol SyMusicPlayerManagerDelegate : AnyObject {
    func updateProgressWith(progress : Float)
    func changeMusicToIndex(index : Int)
    func updateBufferProgress(progress : Float)
}

//全局通知 name
let SyMusicPlayerManagerState = "SyMusicPlayerManagerState"
let CurrentPlayUrl = "CurrentPlayUrl"
let PlayType = "PlayType"

class SyMusicPlayerManager: NSObject {
    
    private static var _sharedInstance: SyMusicPlayerManager?
    // player 单例
    class func getSharedInstance() -> SyMusicPlayerManager {
        guard let instance = _sharedInstance else {
            _sharedInstance = SyMusicPlayerManager()
            return _sharedInstance!
        }
        return instance
    }
    
    //销毁单例对象
    class func avPlayerDestroy() {
        _sharedInstance = nil
    }
    
    var player: AVPlayer = {
        let _player = AVPlayer()
        //不设置这个属性值 音频会等待10s左右 添加上后3s左右就可以播放
        _player.automaticallyWaitsToMinimizeStalling = false
        _player.volume = 2.0 //默认最大音量
        return _player
    }()// 播放器
    
    var playerItem: AVPlayerItem?  // 类似于播放磁碟
    var currentUrl: String?     //当前播放链接
    
    var isPlay: Bool = false //是否正在播放
    var isEnterBackground: Bool = false     //应用是否进入后台
    var seekToZeroBeforePlay: Bool = false  //播放前是否跳到 0
    
    var isImmediately: Bool = false   //是否立即播放
    var isEmptyBufferPause: Bool = false //没加载玩是否暂停
    var isFinish: Bool = false      //是否播放结束
    var isSeekingToTime: Bool = false // 是否正在拖动slide  调整播放时间
    
    var durantion: Float64 {
        if let duration = self.player.currentItem?.duration {
            return CMTimeGetSeconds(duration)
        }
        return  0.0
    }
    var progress: Float = 0.0  //播放进度
    var currentIndex: Int = 0   //当前播放
    var payStatus: Bool = false //课程是否付费
    //当你播放的不仅仅是音乐的话，而是多种类型的音频 例如： 试听，问题回答，音乐连续播 等等
    // 这时一定要提前分好类  会好一点
    var playType: SyMusicPlayerManagerType = SyMusicPlayerManagerType.PlayTypeTry  //1 景点，线路  2 专题播放  3 试听  4 回答问题 5 其他
    
    // 播放速度    改变播放速度
    var playSpeed: Float = 1.0 {
        didSet{
            if (self.isPlay){
                guard let playerItem = self.playerItem else {return}
                self.enableAudioTracks(enable: true, playerItem: playerItem)
                self.player.rate = playSpeed
            }
        }
    }
    
    weak var delegate : SyMusicPlayerManagerDelegate?
    var timeObserVer : Any?
    var musicItem: SyMusicsItem?
    var imageView = UIImageView() //为了设置锁屏封面
    // 音频播放数组  例如 多个需要连续播放的音频 用比较好
    var musicArray : [SyMusicsItem] = []
    fileprivate var lastRow = -1
    fileprivate var artWork: MPMediaItemArtwork?
    
    func getLrcMs(_ lrcName: String?) -> [SyLrcItem] {
        if lrcName == nil {
            return [SyLrcItem]()
        }
        guard let path = Bundle.main.path(forResource: lrcName, ofType: nil) else { return [SyLrcItem]() }
        var lrcContent = ""
        do {
            lrcContent = try String(contentsOfFile: path)
        }catch {
            print(error)
            return [SyLrcItem]()
        }
        let timeContentArray = lrcContent.components(separatedBy: "\n")
        var lrcMs = [SyLrcItem]()
        for timeContentStr in timeContentArray {
            if timeContentStr.contains("[ti:") || timeContentStr.contains("[ar:") || timeContentStr.contains("[al:") { continue }
            let resultLrcStr = timeContentStr.replacingOccurrences(of: "[", with: "")
            let timeAndContent = resultLrcStr.components(separatedBy: "]")
            if timeAndContent.count != 2 { continue }
            let time = timeAndContent[0]
            let content = timeAndContent[1]
            lrcMs.append(SyLrcItem(beginTime: Timer.getTimeInterval(time), endTime: Timer.getTimeInterval(time), lrcContent: content))
        }
        
        for i in 0..<lrcMs.count {
            if i == lrcMs.count - 1 { break }
            lrcMs[i].endTime = lrcMs[i + 1].beginTime
        }
        return lrcMs
    }
    
    func getCurrentLrcM(_ currentTime: TimeInterval, lrcMs: [SyLrcItem]) -> (row: Int, lrcM: SyLrcItem?) {
        for i in 0..<lrcMs.count {
            if  currentTime >= lrcMs[i].beginTime && currentTime < lrcMs[i].endTime {
                return (i, lrcMs[i])
            }
        }
        return (0, nil)
    }
    
    //加载本地.plist文件数据
    class func plistData(pathStr: String) -> [SyMusicsItem] {
        guard let plistUrl = Bundle.main.path(forResource: pathStr + "Musics", ofType: "plist") else { return [] }
        do {
            let plistData = try Data(contentsOf: URL(fileURLWithPath: plistUrl))
            let plist = try PropertyListSerialization.propertyList(from: plistData, options: .mutableContainers, format: nil)
            let dataArry = plist as! [[String:String]]
            var musicMs = [SyMusicsItem]()
            for dic in dataArry {
//                SyPrint("name=>>\(dicForValue(dic: dic as NSDictionary, key: "name"))")
                let dicValue = dic as NSDictionary
                musicMs.append(SyMusicsItem(id: dicForValue(dic: dicValue, key: "id"),
                                            category: dicForValue(dic: dicValue, key: "category"),
                                            name: dicForValue(dic: dicValue, key: "name"),
                                            icon: dicForValue(dic: dicValue, key: "icon"),
                                            singerIcon: dicForValue(dic: dicValue, key: "singerIcon"),
                                            singer: dicForValue(dic: dicValue, key: "singer"),
                                            lrcname: dicForValue(dic: dicValue, key: "lrcname"),
                                            filename: dicForValue(dic: dicValue, key: "filename")))
            }
            return musicMs
        } catch {
            SyPrint(error.localizedDescription)
        }
        return []
    }
    
    class func dataSource(star: MusicStar,_ result: ([SyMusicsItem])->()) {
        result(plistData(pathStr: star.rawValue))
    }
    
    /*/是否免费可播放
     func isFreeToPlay(model: SyMainModel) -> Bool {
     if self.payStatus { //表示已付费
     return true
     }else{
     if model.isFree == "0" {
     return true
     }else{
     //2.8.5版本 添加论道模块 收费的课程提示 升级app
     //            progressHUDShowWarningWithStatus(status: strFromCommon(key: "sq_app_version_tip"))
     progressHUDShowWarningWithStatus(status: strFromCommon(key: "sq_please_buy_calss_tip"))
     }
     }
     return false
     }*/
    
    private override init() {
        super.init()
        //允许应用接收远程控制
        UIApplication.shared.beginReceivingRemoteControlEvents()
        //设置并激活音频会话类别
        let session = AVAudioSession.sharedInstance()
        //        PopoverView.setAVAudioSessionCategory(.playback)
        do {
            try session.setCategory(AVAudioSession.Category.playback)//后台播放
            try session.setActive(true)
        }catch {
            print(error)
            return
        }
        initPlayer()
    }
    
    //播放器初始化
    func initPlayer() {
        self.playSpeed = 1.0 //播放前初始化倍速 1.0
        self.player.rate = 1.0
    }
    
    // 播放前增加配置 监测
    func currentItemAddObserver(){
        //监听是否靠近耳朵
        //NotificationCenter.default.addObserver(self, selector: #selector(sensorStateChange), name:UIDevice.proximityStateDidChangeNotification, object: nil)
        
        //播放期间被 电话 短信 微信 等打断后的处理
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterreption(sender:)), name:AVAudioSession.interruptionNotification, object:AVAudioSession.sharedInstance())
        
        // 监控播放结束通知
        NotificationCenter.default.addObserver(self, selector: #selector(playMusicFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        //监听状态属性 ，注意AVPlayer也有一个status属性 通过监控它的status也可以获得播放状态
        
        self.player.currentItem?.addObserver(self, forKeyPath: "status", options:[.new,.old], context: nil)
        
        //监控缓冲加载情况属性
        self.player.currentItem?.addObserver(self, forKeyPath:"loadedTimeRanges", options: [.new,.old], context: nil)
        
        self.timeObserVer = self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] (time) in
            
            guard let `self` = self else { return }
            
            let currentTime = CMTimeGetSeconds(time)
            self.progress = Float(currentTime)
            if self.isSeekingToTime {
                return
            }
            
            let total = self.durantion
            if total > 0 {
                let progressValue = Float(currentTime) / Float(total)
                //SyPrint("currentTime->\(currentTime) total->\(total) progressValue->\(progressValue)")
                self.delegate?.updateProgressWith(progress: progressValue)
                if progressValue > 0 {
                    guard let windows: [UIView] = UIApplication.shared.keyWindow?.subviews else { return }
                    windows.forEach { (view) in
                        if view.classForCoder == SyMusicPlayerShowView().classForCoder{
                            let v = view as? SyMusicPlayerShowView
                            v?.playerShowViewProgress.progress = progressValue
                            v?.playerShowViewHeaderImage.image = UIImage(named: self.musicItem?.icon ?? "")
                            //v?.playerShowViewTitleLab.text = SyMusicPlayerManager.getSharedInstance().model?.name
                            let rowLrcM = SyMusicPlayerManager.getSharedInstance().getCurrentLrcM(currentTime, lrcMs: SyMusicPlayerManager.getSharedInstance().getLrcMs(SyMusicPlayerManager.getSharedInstance().musicItem?.lrcname))
                            let lrcM = rowLrcM.lrcM
                            v?.playerShowViewTitleLab.text = lrcM?.lrcContent//更新歌词，固定的单行歌词
                        }
                    }
                }
            }
        }
    }
    
    // 播放后   删除配置 监测
    func currentItemRemoveObserver(){
        self.player.currentItem?.removeObserver(self, forKeyPath:"status")
        self.player.currentItem?.removeObserver(self, forKeyPath:"loadedTimeRanges")
        
        //NotificationCenter.default.removeObserver(self, name:UIDevice.proximityStateDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name:AVAudioSession.interruptionNotification, object: nil)
        
        if(self.timeObserVer != nil){
            self.player.removeTimeObserver(self.timeObserVer!)
        }
    }
    
    /*/监测是否靠近耳朵  转换声音播放模式
     @objc func sensorStateChange() {
     DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
     if UIDevice.current.proximityState == true {
     //靠近耳朵
     do {
     try self.session.setCategory(AVAudioSession.Category.playAndRecord)//后台播放
     }catch {
     print(error)
     return
     }
     }else {
     //远离耳朵
     do {
     try self.session.setCategory(AVAudioSession.Category.playback)//后台播放
     }catch {
     print(error)
     return
     }
     }
     }
     }*/
    
    // 处理播放音频是被来电 或者 其他 打断音频的处理
    @objc func handleInterreption(sender:NSNotification) {
        let info = sender.userInfo
        guard let type : AVAudioSession.InterruptionType =  info?[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType else { return }
        if type == AVAudioSession.InterruptionType.began {
            self.pause()
        }else {
            guard  let options = info![AVAudioSessionInterruptionOptionKey] as? AVAudioSession.InterruptionOptions else {return}
            if(options == AVAudioSession.InterruptionOptions.shouldResume){
                self.pause()
            }
        }
    }
    
    // 单个音频播放结束后的逻辑处理
    @objc func playMusicFinished(){
        //只要有物品靠近手机屏幕就会变暗
        //        UIDevice.current.isProximityMonitoringEnabled = true
        self.seekToZeroBeforePlay = true
        self.isPlay = false
        self.updateCurrentPlayState(state: AVPlayerPlayState.AVPlayerPlayStateEnd)
        if (self.playType == SyMusicPlayerManagerType.PlayTypeLine ||
            self.playType == SyMusicPlayerManagerType.PlayTypeSpecial) {
            if userDefaultsForString(forKey: cycleVoiceStateKey()) == "1" {
                self.current()
            }else{
                self.next()
                //下一个音频需要刷新 SQPlayerShowView 控件的数据
                guard let windows: [UIView] = UIApplication.shared.keyWindow?.subviews else { return }
                windows.forEach { (view) in
                    if view.classForCoder == SyMusicPlayerShowView().classForCoder{
                        if SyMusicPlayerManager.getSharedInstance().musicArray.count > SyMusicPlayerManager.getSharedInstance().currentIndex{
                            let v = view as? SyMusicPlayerShowView
                            let item = SyMusicPlayerManager.getSharedInstance().musicArray[SyMusicPlayerManager.getSharedInstance().currentIndex]
                            v?.playerShowViewHeaderImage.image = UIImage.init(named: item.name)
                        }
                    }
                }
            }
        }
    }
}

extension SyMusicPlayerManager {
    func resetPlaySeed(){
        self.playSpeed = 1.0
    }
    //设置播放速率
    func setPlaySpeed(playSpeed:Float) {
        if self.isPlay{
            self.enableAudioTracks(enable: true, playerItem: self.playerItem!)
            self.player.rate = playSpeed;
        }
        self.playSpeed = playSpeed
    }
    
    /// 改变播放速率  必实现的方法
    ///
    /// - Parameters:
    ///   - enable:
    ///   - playerItem: 当前播放
    func enableAudioTracks(enable:Bool,playerItem : AVPlayerItem){
        for track : AVPlayerItemTrack in playerItem.tracks {
            if track.assetTrack?.mediaType == AVMediaType.audio {
                track.isEnabled = enable
            }
        }
    }
    
    /// 对网络音频和本地音频 地址 做统一管理
    func loadAudioWithPlaypath(playpath: String) -> URL{
        return URL(fileURLWithPath: playpath)
    }
    
    /// 用于播放单个音频   播放方法
    ///
    /// - Parameters:
    ///   - url: 播放地址
    ///   - type: 音频类型  （以便于播放多种类型的音频）
    func playMusic(url :String, type :SyMusicPlayerManagerType){
        if url.trimmingCharactersCount > 0 {
            self.playType = type // 记录播放类型 以便做出不同处理
            self.setPlaySpeed(playSpeed: 1.0) //播放前初始化倍速 1.0
            self.currentItemRemoveObserver() //移除上一首的通知 观察
            //        let playUrl = self.loadAudioWithPlaypath(playpath: url)
            let playerItem = AVPlayerItem(url: URL(string: url)!)
            self.playerItem = playerItem
            self.currentUrl = url
            self.isImmediately = true
            
            self.player.replaceCurrentItem(with: playerItem)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            self.currentItemAddObserver()
        }
    }
    
    /// 用于播放多个音频的列表  播放方法
    ///
    /// - Parameters:
    ///   - index: 播放列表中的第几个音频
    ///   - isImmediately: 是否立即播放
    func playTheLine(index :Int,isImmediately :Bool){
        self.currentItemRemoveObserver()
        self.playType = .PlayTypeLine // 记录播放类型 以便做出不同处理
        
        let record = self.musicArray[index]
        if record.name.trimmingCharactersCount > 0 {
            guard let playUrl = Bundle.main.url(forResource: record.filename, withExtension: nil) else {return}
            let playerItem = AVPlayerItem(url: playUrl)
            //            let playerItem = AVPlayerItem(url: URL(string: record.name)!)
            self.playerItem = playerItem
            self.currentUrl = record.name
            self.isImmediately = isImmediately
            self.musicItem = record
            self.currentIndex = index
            if !isImmediately {
                self.pause()
            }
            self.player.replaceCurrentItem(with: playerItem)
            self.currentItemAddObserver()
        }
    }
    
    //停止  多用于退出界面时
    func stop(){
        self.pause()
        self.isImmediately = false
        self.currentUrl = nil
        self.progress = 0.0
        self.isPlay = false
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    // 播放
    func play(){
        //        SyPrint("开始播放了-->>")
        if self.seekToZeroBeforePlay {
            self.musicSeekToTime(time: 0.0)
            self.updateCurrentPlayState(state: AVPlayerPlayState.AVPlayerPlayStateseekToZeroBeforePlay)
            self.seekToZeroBeforePlay = false
        }
        //        UIDevice.current.isProximityMonitoringEnabled = true
        self.isPlay = true
        self.player.play()
        self.updateCurrentPlayState(state: AVPlayerPlayState.AVPlayerPlayStatePlaying)
        //暂停是改了 播放速率  播放时及时改变播放倍速
        if self.playerItem != nil {
            self.enableAudioTracks(enable: true, playerItem: self.playerItem!)
        }
        self.player.rate = self.playSpeed
        self.setNowPlayingInfo()
    }
    
    /// 暂停
    func pause(){
        self.isPlay = false
        //        UIDevice.current.isProximityMonitoringEnabled = false
        self.updateCurrentPlayState(state: AVPlayerPlayState.AVPlayerPlayStatePause)
        player.pause()
        self.setNowPlayingInfo()
    }
    
    //播放当前这首（单曲循环）
    func current() {
        if self.playType == SyMusicPlayerManagerType.PlayTypeLine || self.playType == SyMusicPlayerManagerType.PlayTypeSpecial {
            let index = self.currentIndex
            self.changeTheMusicByIndex(index: index)
        }
    }
    
    /// 下一首
    func next(){
        if self.playType == SyMusicPlayerManagerType.PlayTypeLine || self.playType == SyMusicPlayerManagerType.PlayTypeSpecial {
            let index = self.currentIndex + 1
            let count = self.musicArray.count
            if index >= count {
                SyPrint("已是最后一首了")
                return
            }
            self.changeTheMusicByIndex(index: index)
            /*if self.payStatus { //表示已经付费
             self.changeTheMusicByIndex(index: index)
             }else{
             if count > index {
             SyPrint("title=> \(self.musicArray[index].chapterTitle)")
             if self.musicArray[index].isFree == "1" { //0免费 1不免费
             progressHUDShowWarningWithStatus(status: strFromCommon(key: "sq_please_buy_calss_tip"))
             }else{ //没有付费但是可以免费听
             self.changeTheMusicByIndex(index: index)
             }
             }
             }*/
        }
    }
    
    /// 上一首
    func previous(){
        if self.playType == SyMusicPlayerManagerType.PlayTypeLine || self.playType == SyMusicPlayerManagerType.PlayTypeSpecial {
            let index = self.currentIndex - 1
            if index < 0 {
                SyPrint("已是第一个了")
                return
            }
            self.changeTheMusicByIndex(index: index)
            /*
             if self.payStatus {
             self.changeTheMusicByIndex(index: index)
             }else{
             if self.musicArray.count > index {
             SyPrint("title=> \(self.musicArray[index].chapterTitle)")
             if self.musicArray[index].isFree == "1" { //0免费 1不免费
             progressHUDShowWarningWithStatus(status: strFromCommon(key: "sq_please_buy_calss_tip"))
             }else{
             self.changeTheMusicByIndex(index: index)
             }
             }
             }*/
        }
    }
    
    /// 跳到 指定的时间点 播放
    ///
    /// - Parameter time: 指定时间点
    func musicSeekToTime(time :Float) {
        guard let durantion = self.player.currentItem?.duration, !durantion.isIndefinite else {
            return
        }
        let interval = CMTimeGetSeconds(durantion)
        self.isSeekingToTime = true
        if interval != 0 {
            let seekTime = CMTimeMake(value: Int64(Float64(time) * interval), timescale: 1)
            self.player.seek(to: seekTime) { (complete) in
                self.isSeekingToTime = false
                self.setNowPlayingInfo()
            }
        }else {
            let seekTime = CMTimeMake(value: 0, timescale: 1)
            self.player.seek(to: seekTime) { (complete) in
                self.isSeekingToTime = false
                self.setNowPlayingInfo()
            }
            self.progress = 0
        }
    }
    
    //更新锁屏界面信息
    func setupLockMessage() {
//        musicMessageM.musicM = self.model
//        if let current = self.player.currentItem?.currentTime(){
//            musicMessageM.costTime = CMTimeGetSeconds(current)
//        }
//        musicMessageM.totalTime = self.durantion
//        musicMessageM.isPlaying = self.isPlay
        guard let item = self.musicItem else { return }
        let musicMessageM = SyMusicMessageItem(musicM: item, costTime: CMTimeGetSeconds((self.player.currentItem?.currentTime())!), totalTime: self.durantion, isPlaying: self.isPlay)
        let center = MPNowPlayingInfoCenter.default()
        
        let musicName = musicMessageM.musicM.name
        let singerName = musicMessageM.musicM.singer
        let costTime = musicMessageM.costTime
        let totalTime = musicMessageM.totalTime
        
        let lrcFileName = musicMessageM.musicM.lrcname
        let lrcMs = self.getLrcMs(lrcFileName)
        let lrcModelAndRow = self.getCurrentLrcM(musicMessageM.costTime, lrcMs: lrcMs)
        let lrcM = lrcModelAndRow.lrcM
        
        if self.lastRow != lrcModelAndRow.row {
            self.lastRow = lrcModelAndRow.row
            if let resultImage = UIImage.getNewImage(UIImage(named: musicMessageM.musicM.icon), str: lrcM?.lrcContent){
                self.artWork = MPMediaItemArtwork(boundsSize: resultImage.size, requestHandler: { size in
                    return resultImage
                })
            }
        }
        
        let dic: NSMutableDictionary = [
            MPMediaItemPropertyAlbumTitle: musicName,
            MPMediaItemPropertyArtist: singerName,
            MPMediaItemPropertyPlaybackDuration: totalTime,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: costTime
        ]
        if self.artWork != nil {
            dic.setValue(self.artWork!, forKey: MPMediaItemPropertyArtwork)
        }
        
        let dicCopy = dic.copy()
        center.nowPlayingInfo = dicCopy as? [String: Any]
    }
    
    // 设置锁屏时 播放中心的播放信息
    func setNowPlayingInfo(){
        if (self.playType == .PlayTypeLine || self.playType == .PlayTypeSpecial) && self.musicItem != nil {
            var info = Dictionary<String,Any>()
            info[MPMediaItemPropertyTitle] = self.musicItem?.name
            /*if  let url = self.model?.imgUrl ,let image = UIImage(named: "item_black_logo_icon"){
             imageView.kf.setImage(with: URL(string:url), placeholder: image, options: nil, progressBlock: nil) { (img, _, _, _) in
             if img != nil {
             info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image:img!)//显示的图片
             }
             }
             }else{*/
            if let image = UIImage(named: "item_headphone_icon"){
                info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { size in
                    return image
                })//MPMediaItemArtwork(image:image)//显示的图片
            }
            //            }
            
            info[MPMediaItemPropertyPlaybackDuration] = self.durantion //总时长
            if let duration = self.player.currentItem?.currentTime() {
                info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(duration)
            }
            
            info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0//播放速率
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
    }
    
    /// 上一首 下一首切换时  以便于播放界面做相应的调整
    ///
    /// - Parameter index: 当前播放
    func changeTheMusicByIndex(index : Int){
        self.playTheLine(index: index, isImmediately: true)
        delegate?.changeMusicToIndex(index: index)
    }
    
    /// 实时更新播放状态  全局通知（便于多个地方都用到音频播放，改变播放状态）
    ///
    /// - Parameter state: 播放状态
    func updateCurrentPlayState(state : AVPlayerPlayState){
        if self.currentUrl != nil {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SyMusicPlayerManagerState), object: nil, userInfo: [SyMusicPlayerManagerState : state,CurrentPlayUrl : self.currentUrl!,PlayType : self.playType])
        }else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SyMusicPlayerManagerState), object: nil, userInfo: [SyMusicPlayerManagerState : state,CurrentPlayUrl : "",PlayType : self.playType])
        }
    }
    
    func timeFormatted(totalSeconds: Float64) -> String{
        let interval = TimeInterval(totalSeconds)
        return interval.durationText
    }
    
    /// 当前播放时间
    var currentTime: String {
        if let current = self.player.currentItem?.currentTime(){
            return timeFormatted(totalSeconds: CMTimeGetSeconds(current))
        }
        return ""
    }
    
    /// 播放音频总时长
    var totalTime : String {
        return self.timeFormatted(totalSeconds:self.durantion)
    }
    
    /// 观察者   播放状态  和  缓冲进度
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //        SyPrint("观察者 -- 播放状态")
        let item = object as! AVPlayerItem
        if keyPath == "status" {
            /*var  status:AVPlayerItemStatus = AVPlayerItemStatus.unknown
             if change != nil {
             let arr = change?[NSKeyValueChangeKey.newKey] as! Array<Any>
             status = change?[NSKeyValueChangeKey.newKey] as! AVPlayerItemStatus
             }*/
            //            SyPrint("status=>\(item.status.rawValue)")
            switch item.status {
            case AVPlayerItem.Status.readyToPlay:
                //                SyPrint("准备播放了-->>")
                if isImmediately {
                    self.play()
                }else{
                    self.setNowPlayingInfo()
                }
            case AVPlayerItem.Status.failed,AVPlayerItem.Status.unknown:
                self.updateCurrentPlayState(state: AVPlayerPlayState.AVPlayerPlayStateNotPlay)
            default:
                break
            }
        }else if keyPath == "loadedTimeRanges" {
            let array = item.loadedTimeRanges
            let timeRange = array.first?.timeRangeValue
            guard let start = timeRange?.start , let end = timeRange?.end else {
                return
            }
            
            let startSeconds = CMTimeGetSeconds(start)
            let durationSeconds = CMTimeGetSeconds(end)
            let totalBuffer = startSeconds + durationSeconds
            let total = self.durantion
            if totalBuffer != 0  && total != 0{
                delegate?.updateBufferProgress(progress: Float(totalBuffer) / Float(total))
                //                SyPrint("加载中-> \(Float(totalBuffer) / Float(total))")
            }
        }
    }
}

