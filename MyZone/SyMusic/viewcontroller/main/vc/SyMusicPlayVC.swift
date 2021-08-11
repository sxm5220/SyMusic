//
//  SyMusicPlayVC.swift
//  SyMusic
//
//  Created by sxm on 2020/5/18.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit

extension SyMusicPlayVC: SyAudioPlayerViewDelegate {
    //上一曲
    func preMusicActionFunc() {
        if SyAVPlayer.getSharedInstance().playType == SyAVPlayerType.PlayTypeLine || SyAVPlayer.getSharedInstance().playType == SyAVPlayerType.PlayTypeSpecial {
            let index = SyAVPlayer.getSharedInstance().currentIndex - 1
            if index < 0 {
                self.view.makeToast(strCommon(key: "sy_first_song_title"))
                return
            }
            SyAVPlayer.getSharedInstance().changeTheMusicByIndex(index: index)
            self.changePlay()
        }
    }
    
    //下一曲
    func nextMusicActionFunc() {
        if SyAVPlayer.getSharedInstance().playType == SyAVPlayerType.PlayTypeLine || SyAVPlayer.getSharedInstance().playType == SyAVPlayerType.PlayTypeSpecial {
            let index = SyAVPlayer.getSharedInstance().currentIndex + 1
            let count = SyAVPlayer.getSharedInstance().musicArray.count
            if index >= count {
                self.view.makeToast(strCommon(key: "sy_last_song_title"))
                return
            }
            SyAVPlayer.getSharedInstance().changeTheMusicByIndex(index: index)
            self.changePlay()
        }
    }
    
    func playListActionFunc() {
        let frame = CGRect.init(x: 0, y: 0, width: screenWidth(), height: screenHeight())
        let listView = SyChooseListView(frame: frame, dataSource: self.dataCourseArray)
        listView.myClosure = { (id: String) -> Void in
            for i in 0..<SyAVPlayer.getSharedInstance().musicArray.count {
                let model: SyMusicsItem = SyAVPlayer.getSharedInstance().musicArray[i]
                if id == model.id {
                    SyAVPlayer.getSharedInstance().playTheLine(index: i, isImmediately: true)
                    self.changePlay()
                }
            }
        }
        self.view.addSubview(listView)
    }
    
    //切换歌曲的时候（上/下一首）
    func changePlay() {
        self.title = SyAVPlayer.getSharedInstance().model?.name
        SyAVPlayer.getSharedInstance().pause()
        self.playView.indicator.startAnimating()
    }
}

class SyMusicPlayVC: SyBaseVC {
    var model: SyMusicsItem!
    var dataCourseArray: [SyMusicsItem] = [SyMusicsItem]()
    var categoryId: String?
    public var star: MusicStar!
    
    lazy var bgImageView: UIImageView = {
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth(), height: screenHeight()))
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        v.clipsToBounds = true
        v.image = UIImage.init(named: SyAVPlayer.getSharedInstance().model?.singerIcon ?? "item_headphone_icon")
        //初始化一个基于模糊效果的视觉效果视图
        let blur = UIBlurEffect(style: .systemMaterialDark)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let windows: [UIView] = UIApplication.shared.keyWindow?.subviews else { return }
        windows.forEach { (view) in
            if view.classForCoder == SyPlayerShowView().classForCoder{
                userDefaultsSetValue(value: "0", key: voicePlayKey())
                view.removeFromSuperview()
            }
        }
        
        let v = SyPlayerShowView(frame: CGRect(x: 2, y: screenHeight(), width: screenWidth() - 4, height: 50), isShow: true, categoryId: self.categoryId,star: self.star)
        UIView.animate(withDuration: 0.5, animations: {
//            v.playerShowViewTitleLab.text = self.title
            //            v.playerShowViewHeaderImage.sd_setImage(with: URL(string: SyAVPlayer.getSharedInstance().model?.imgUrl ?? ""), placeholderImage: #imageLiteral(resourceName: "item_black_logo_icon"))
            v.playerShowViewHeaderImage.image = UIImage(named: self.model?.icon ?? "")
            v.frame.origin.y = currentViewController()?.navigationController?.viewControllers.count == 1 ? (screenHeight() - (isIphoneX() ? 135 : 100)) : screenHeight()
            userDefaultsSetValue(value: "1", key: voicePlayKey())
        }, completion: { (isCompletion) in
            UIApplication.shared.keyWindow?.addSubview(v)
        })
        //歌词定时器移除
        self.playView.removeLink()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isBackBar = true
        self.title = self.model.name
        self.view.addSubview(self.bgImageView)
        self.view.addSubview(self.playView)
        self.musicListDataSource(isRefresh: true)
    }
    
    override func viewWillLayoutSubviews() {//尺寸类的放在这里进行调整，以获取到最终的正确尺寸
        super.viewWillLayoutSubviews()
        self.playView.lrcVC.tableView.frame = self.playView.lrcScrollView.bounds//歌词视图大小调整
        self.playView.lrcVC.tableView.frame.origin.x = self.playView.lrcScrollView.frame.size.width//默认放在最右边，滚动时出现
        self.playView.lrcScrollView.contentSize = CGSize(width: self.playView.lrcScrollView.frame.size.width * 2, height: 0)//scroll，要实现滚动的前提是要有contentSize，2页的大小
        self.playView.centerImageView.layer.cornerRadius = self.playView.centerImageView.frame.size.width * 0.5//大图片圆形效果
        self.playView.centerImageView.layer.masksToBounds = true
    }
    
    fileprivate func musicListDataSource(isRefresh: Bool) {
        SyAVPlayer.dataSource(star: self.star) { (models: [SyMusicsItem]) in
            self.dataCourseArray = models
            if SyAVPlayer.getSharedInstance().musicArray.count > 0 {
                SyAVPlayer.getSharedInstance().musicArray.removeAll()
            }
            SyAVPlayer.getSharedInstance().musicArray = self.dataCourseArray
            for i in 0..<SyAVPlayer.getSharedInstance().musicArray.count {
                let model: SyMusicsItem = SyAVPlayer.getSharedInstance().musicArray[i]
                if self.model.id == model.id {
                    if SyAVPlayer.getSharedInstance().model?.id != model.id { //判断是否当前播放中歌曲
                        SyAVPlayer.getSharedInstance().playTheLine(index: i, isImmediately: true)
                    }
                }
            }
        }
    }
}
