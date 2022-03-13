//
//  SyMainDetailVC.swift
//  SyMusic
//
//  Created by sxm on 2020/5/15.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh

class SyMainDetailVC: SyBaseVC {
    private let heightValue: CGFloat = 160.0
    public var useritem: userItem!
    private var isCategoryId: Bool = false //是否是点击的歌曲类别
    private var dataCourseArray: [SyMusicsItem] = [SyMusicsItem]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private lazy var headImageView: UIImageView = {
        var imgView = UIImageView(frame: CGRect(x: 20, y: 20, width: screenWidth() - 100, height: heightValue))
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 20
        return imgView
    }()
    
    private lazy var headView: UIView = {
        var headView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth(), height: heightValue + 40))
        headView.backgroundColor = UIColor.clear
        headView.addSubview(self.headImageView)
        return headView
    }()
    
    private lazy var tableView: SyTableView = {
        let heightValue: CGFloat = (screenHeight() - navigationBarWithHeight() - 50)
        var tableView = SyTableView(array: [30,0,screenWidth() - 60,heightValue], .plain, self)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = rgbWithValue(r: 220, g: 220, b: 220, alpha: 0.2)
        tableView.tableHeaderView = self.headView
        tableView.separatorInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
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
        self.view.addSubview(self.tableView)
        self.title = self.useritem.name
        self.headImageView.image = UIImage.init(named: self.useritem?.icon ?? "")
        
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        let indexValue: Int = sender.view?.tag ?? -1
        if self.dataCourseArray.count > indexValue {
            self.pushVC(index: indexValue)
        }
    }
    
    fileprivate func musicListDataSource(isRefresh: Bool) {
        SyMusicPlayerManager.dataSource(star: self.useritem.star) { (models: [SyMusicsItem]) in
            self.dataCourseArray = models
            if self.dataCourseArray.count > 0 {
                //表明已经有歌曲资源播放列表了
                if SyMusicPlayerManager.getSharedInstance().musicArray.count > 0 {
                    let musicCategoryId = SyMusicPlayerManager.getSharedInstance().musicArray[0].category
                    //当前目录是正在播放中的目录歌曲
                    self.isCategoryId = self.useritem.id == musicCategoryId ? true : false
                }else{ //表明第一次加载歌曲资源播放列表
                    SyMusicPlayerManager.getSharedInstance().musicArray = self.dataCourseArray
                }
            }
            self.loadDataComplete()
        }
    }
    
    fileprivate func loadDataComplete() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.mj_header?.endRefreshing()
        }
    }
    
    fileprivate func pushVC(index: Int) {
        if self.dataCourseArray.count > index {
            let item = self.dataCourseArray[index]
            //同一类目下，点击歌曲，没有播放就开始播放，如果正在播放就不管，如果有歌曲播放就暂停播放点击的歌曲
            //不是同一类目下，点击歌曲，如果正在播放就暂停，换成该目录下的歌曲去播放，如果没有歌曲播放就播放该歌曲
            if self.isCategoryId && SyMusicPlayerManager.getSharedInstance().musicItem?.id == item.id {
                if !SyMusicPlayerManager.getSharedInstance().isPlay {
                    SyMusicPlayerManager.getSharedInstance().player.play()
                }
            }else{
                if SyMusicPlayerManager.getSharedInstance().isPlay {
                    SyMusicPlayerManager.getSharedInstance().player.pause()
                }
                //从当前音乐目录，转到其他播放目录下，点击播放时，要清除播放数据源换成新的（转到其他播放目录下）数据源
                if !self.isCategoryId && SyMusicPlayerManager.getSharedInstance().musicItem?.id != nil {
                    SyMusicPlayerManager.getSharedInstance().musicArray.removeAll()
                    SyMusicPlayerManager.getSharedInstance().musicArray = self.dataCourseArray
                }
                SyMusicPlayerManager.getSharedInstance().playTheLine(index: index, isImmediately: true)
            }

            let vc = SyMusicPlayVC()
            vc.star = self.useritem.star
            vc.categoryId = self.useritem.id
            vc.musicItem = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension SyMainDetailVC: UITableViewDelegate, UITableViewDataSource {
    
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
            let headerImageView = UIImageView(frame: CGRect(x: screenWidth() - 70 - 60, y: 15, width: 50, height: 50))
            headerImageView.layer.cornerRadius = headerImageView.bounds.size.height / 2
            headerImageView.isUserInteractionEnabled = true
            headerImageView.clipsToBounds = true
            headerImageView.layer.borderWidth = 0.5
            headerImageView.layer.borderColor = UIColor.lightGray.cgColor
            headerImageView.contentMode = .scaleAspectFill
            headerImageView.image = UIImage(named: musicItem.singerIcon)
            headerImageView.tag = indexPath.row
            headerImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:))))

            cell.contentView.addSubview(headerImageView)
            
            let imgV = UIImageView(frame: CGRect(x: 5, y: 30, width: 20, height: 20))
            imgV.animationImages = [#imageLiteral(resourceName: "item_play01_icon"),#imageLiteral(resourceName: "item_play02_icon"),#imageLiteral(resourceName: "item_play03_icon"),#imageLiteral(resourceName: "item_play03_icon"),#imageLiteral(resourceName: "item_play02_icon"),#imageLiteral(resourceName: "item_play01_icon")]
            imgV.animationDuration = 1.2
            imgV.animationRepeatCount = 0
            imgV.stopAnimating()
            cell.contentView.addSubview(imgV)
            
            //名称
            let titleLabel = SyLabel(frame: CGRect(x: imgV.frame.maxX + 10, y: 15, width: cell.bounds.size.width - 70, height: 20), text: musicItem.name, textColor: .lightGray, font: UIFont.systemFont(ofSize: 14), textAlignment: .left)
            cell.contentView.addSubview(titleLabel)
            
            //演唱者
            let singerLabel = SyLabel(frame: CGRect(x: titleLabel.frame.origin.x, y: titleLabel.frame.maxY + 5, width: titleLabel.bounds.size.width, height: 20), text: musicItem.singer, textColor: titleLabel.textColor, font: UIFont.systemFont(ofSize: 10), textAlignment: .left)
            cell.contentView.addSubview(singerLabel)
            
            if SyMusicPlayerManager.getSharedInstance().musicArray.count > SyMusicPlayerManager.getSharedInstance().currentIndex{
                if SyMusicPlayerManager.getSharedInstance().musicArray[SyMusicPlayerManager.getSharedInstance().currentIndex].id == musicItem.id &&
                    SyMusicPlayerManager.getSharedInstance().musicArray[SyMusicPlayerManager.getSharedInstance().currentIndex].category == self.useritem.id &&
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
                    singerLabel.font = UIFont.boldSystemFont(ofSize: 12)
                    singerLabel.textColor = titleLabel.textColor
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
