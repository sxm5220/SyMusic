//
//  SyAlbumMusicListVC.swift
//  SyMusic
//
//  Created by sxm on 2020/5/15.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh

class SyAlbumMusicListVC: SyBaseVC {
    private let heightValue: CGFloat = 180.0
    public var albumItem: SyAlbumItem!
    public var useritem: userItem!
    public var composerId: String!
    private var isCurrentPlayMusic: Bool = false //是否是当前正在播放的歌曲
    private var dataCourseArray: [SyMusicsItem] = [SyMusicsItem]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private lazy var headImageView: UIImageView = {
        var imgView = UIImageView()
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 20
        return imgView
    }()
    
    private lazy var headView: UIView = {
        var headView = UIView()
        headView.backgroundColor = UIColor.clear
        headView.addSubview(self.headImageView)
        return headView
    }()
    
    private lazy var tableView: SyTableView = {
        var tableView = SyTableView(style: .grouped, delegate: self)
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.separatorColor = rgbWithValue(r: 220, g: 220, b: 220, alpha: 0.2)
        tableView.tableHeaderView = self.headView
        tableView.separatorInset = UIEdgeInsets(top: 5, left: 40, bottom: 5, right: 40)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.musicListDataSource(isRefresh: true)
        })
        tableView.mj_header?.beginRefreshing()
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    
    @objc
    func playBarChangePlayStateWith(notif : Notification){
        guard let state = notif.userInfo?[SyMusicPlayerManagerState] as? AVPlayerPlayState else {return}
        if state == .AVPlayerPlayStatePlaying {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(playBarChangePlayStateWith(notif:)), name: NSNotification.Name(rawValue: SyMusicPlayerManagerState), object: nil)
        
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isBackBar = true
        self.title = self.albumItem.albumName
        
        self.view.addSubview(self.tableView)
        self.headImageView.image = UIImage.init(named: self.useritem?.icon ?? "")
        
        self.tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        self.headView.snp.makeConstraints { make in
            make.height.equalTo(heightValue)
            make.width.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.headImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 40, bottom: 10, right: 40))
        }
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        let indexValue: Int = sender.view?.tag ?? -1
        if self.dataCourseArray.count > indexValue {
            self.pushVC(index: indexValue)
        }
    }
    
    fileprivate func musicListDataSource(isRefresh: Bool) {
        self.dataCourseArray = self.albumItem.albumData
        if self.dataCourseArray.count > 0 {
            //当前目录是正在播放中的目录歌曲
            //同一作家和同一个专辑
            if self.useritem.id == SyMusicPlayerManager.getSharedInstance().composerId &&
                self.albumItem.albumId == SyMusicPlayerManager.getSharedInstance().albumItem?.albumId{
                self.isCurrentPlayMusic = true
            }else{
                self.isCurrentPlayMusic = false
            }
        }
        self.loadDataComplete()
    }
    
    fileprivate func loadDataComplete() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.mj_header?.endRefreshing()
        }
    }
    
    private func playerManagerDataReload() {
        //歌曲资源播放列表
        SyMusicPlayerManager.getSharedInstance().musicArray = self.dataCourseArray
        //作家（歌手）唯一标识id
        SyMusicPlayerManager.getSharedInstance().composerId = self.composerId
        //专辑id
        SyMusicPlayerManager.getSharedInstance().albumItem = self.albumItem
        //作家（歌手）名字
//        SyMusicPlayerManager.getSharedInstance().singerUser = self.useritem.name
        //专辑的图片（正常的应该是该歌曲对应的图片）
        //SyMusicPlayerManager.getSharedInstance().musicImageName = self.albumItem.albumImage
    }
    
    fileprivate func pushVC(index: Int) {
        if self.dataCourseArray.count > index {
            let item = self.dataCourseArray[index]
            //表明已经有歌曲资源播放列表了
            if SyMusicPlayerManager.getSharedInstance().musicArray.count == 0 {
                self.playerManagerDataReload()
            }
            //同一类目下，点击歌曲，没有播放就开始播放，如果正在播放就不管，如果有歌曲播放就暂停播放点击的歌曲
            //不是同一类目下，点击歌曲，如果正在播放就暂停，换成该目录下的歌曲去播放，如果没有歌曲播放就播放该歌曲
            if self.isCurrentPlayMusic && SyMusicPlayerManager.getSharedInstance().musicItem?.id == item.id {
                if !SyMusicPlayerManager.getSharedInstance().isPlay {
                    SyMusicPlayerManager.getSharedInstance().player.play()
                }
            }else{
                if SyMusicPlayerManager.getSharedInstance().isPlay {
                    SyMusicPlayerManager.getSharedInstance().player.pause()
                }
                //从当前音乐目录，转到其他播放目录下，点击播放时，要清除播放数据源换成新的（转到其他播放目录下）数据源
                if !self.isCurrentPlayMusic && SyMusicPlayerManager.getSharedInstance().musicItem?.id != nil {
                    SyMusicPlayerManager.getSharedInstance().musicArray.removeAll()
                    self.playerManagerDataReload()
                }
                SyMusicPlayerManager.getSharedInstance().playTheLine(index: index, isImmediately: true)
            }

            let vc = SyMusicPlayVC()
            vc.star = self.useritem.star
            vc.musicName = item.musicName
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension SyAlbumMusicListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataCourseArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        if self.dataCourseArray.count > indexPath.row {
            let musicItem = self.dataCourseArray[indexPath.row]
            
            //头像
            let headerImageView = UIImageView()
            headerImageView.layer.cornerRadius = 50 / 2
            headerImageView.isUserInteractionEnabled = true
            headerImageView.clipsToBounds = true
            headerImageView.layer.borderWidth = 0.5
            headerImageView.layer.borderColor = UIColor.lightGray.cgColor
            headerImageView.contentMode = .scaleAspectFill
            headerImageView.image = UIImage(named: self.albumItem.albumImage)//UIImage(named: musicItem.singerIcon)
            headerImageView.tag = indexPath.row
            headerImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:))))
            cell.contentView.addSubview(headerImageView)
            headerImageView.snp.makeConstraints { make in
                make.top.equalTo(15)
                make.trailing.equalToSuperview().offset(-60)
                make.width.height.equalTo(50)
            }
            
            let imgV = UIImageView()
            imgV.animationImages = [#imageLiteral(resourceName: "item_play01_icon"),#imageLiteral(resourceName: "item_play02_icon"),#imageLiteral(resourceName: "item_play03_icon"),#imageLiteral(resourceName: "item_play03_icon"),#imageLiteral(resourceName: "item_play02_icon"),#imageLiteral(resourceName: "item_play01_icon")]
            imgV.animationDuration = 1.2
            imgV.animationRepeatCount = 0
            imgV.stopAnimating()
            cell.contentView.addSubview(imgV)
            imgV.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(30)
                make.top.equalTo(35)
                make.width.height.equalTo(20)
            }
            
            //名称
            let titleLabel = SyMarqueeLabel(text: musicItem.musicName, textColor: .white, font: UIFont.systemFont(ofSize: 15), textAlignment: .left)
            cell.contentView.addSubview(titleLabel)
            
            let singerName = strCommon(key: "sy_composerName") + "：\(musicItem.composerName)"
            let lyricisName = strCommon(key: "sy_lyricisName") + "：\(musicItem.lyricistName)"
            //编曲者
            let detailLabel = SyMarqueeLabel(text: singerName + " " + lyricisName, textColor: .lightGray, font: UIFont.systemFont(ofSize: 12), textAlignment: .left)
            cell.contentView.addSubview(detailLabel)
            
            titleLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(60)
                make.trailing.equalToSuperview().offset(-130)
                make.top.equalTo(20)
                make.height.equalTo(20)
            }
            
            detailLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(60)
                make.trailing.equalToSuperview().offset(-130)
                make.top.equalTo(50)
                make.height.equalTo(20)
            }
            
            let currentIndex = SyMusicPlayerManager.getSharedInstance().currentIndex
            if SyMusicPlayerManager.getSharedInstance().musicArray.count > currentIndex {
                if SyMusicPlayerManager.getSharedInstance().composerId == self.composerId && SyMusicPlayerManager.getSharedInstance().albumItem?.albumId == self.albumItem.albumId && SyMusicPlayerManager.getSharedInstance().musicArray[currentIndex].id == musicItem.id &&
                    SyMusicPlayerManager.getSharedInstance().musicItem?.id != nil { //当前音频播放状态
                    if SyMusicPlayerManager.getSharedInstance().isPlay {
                        imgV.startAnimating()
                        imgV.image = nil
                    }else{
                        imgV.stopAnimating()
                        imgV.image = #imageLiteral(resourceName: "item_play01_icon")
                    }
                    
                    titleLabel.textColor = .white
                    titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.dataCourseArray.count > indexPath.row {
            self.pushVC(index: indexPath.row)
        }
    }
}
