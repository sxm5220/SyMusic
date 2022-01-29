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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isBackBar = true
        self.view.addSubview(self.tableView)
        self.title = self.useritem.name
        self.headImageView.image = UIImage.init(named: self.useritem.icon)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playBarChangePlayStateWith(notif:)), name: NSNotification.Name(rawValue: SyAVPlayerState), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        let indexValue: Int = sender.view?.tag ?? -1
        if self.dataCourseArray.count > indexValue {
            self.pushVC(index: indexValue)
        }
    }
    
    fileprivate func musicListDataSource(isRefresh: Bool) {
        SyAVPlayer.dataSource(star: self.useritem.star) { (models: [SyMusicsItem]) in
            self.dataCourseArray = models
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
        let model = self.dataCourseArray[index]
        if SyAVPlayer.getSharedInstance().isPlay && SyAVPlayer.getSharedInstance().model?.id != model.id{
            SyAVPlayer.getSharedInstance().player.pause()
            SyAVPlayer.getSharedInstance().isPlay = false
        }
        SyAVPlayer.getSharedInstance().isIntroductionDetail = false

        let vc = SyMusicPlayVC()
        vc.star = self.useritem.star
        vc.model = model
        vc.categoryId = self.useritem.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SyMainDetailVC {
    @objc
    func playBarChangePlayStateWith(notif : Notification){
        guard let state = notif.userInfo?[SyAVPlayerState] as? AVPlayerPlayState else {return}
        if state == .AVPlayerPlayStatePlaying {
            self.tableView.reloadData()
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
            let model = self.dataCourseArray[indexPath.row]
            //头像
            let headerImageView = UIImageView(frame: CGRect(x: screenWidth() - 70 - 60, y: 15, width: 50, height: 50))
            headerImageView.layer.cornerRadius = headerImageView.bounds.size.height / 2
            headerImageView.isUserInteractionEnabled = true
            headerImageView.clipsToBounds = true
            headerImageView.layer.borderWidth = 0.5
            headerImageView.layer.borderColor = UIColor.lightGray.cgColor
            headerImageView.contentMode = .scaleAspectFill
            headerImageView.image = UIImage(named: model.singerIcon)
            headerImageView.tag = indexPath.row
            headerImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:))))
            //headerImageView.sd_setImage(with: URL(string: model.headUrl), placeholderImage: #imageLiteral(resourceName: "item_color_5_icon"))
            cell.contentView.addSubview(headerImageView)
            
            let imgV = UIImageView(frame: CGRect(x: 5, y: 30, width: 20, height: 20))
            imgV.animationImages = [#imageLiteral(resourceName: "item_bledevice_playing_01_icon"),#imageLiteral(resourceName: "item_bledevice_playing_02_icon"),#imageLiteral(resourceName: "item_bledevice_playing_03_icon")]
            imgV.animationDuration = 1
            imgV.animationRepeatCount = 0
            imgV.stopAnimating()
            cell.contentView.addSubview(imgV)
            
            //名称
            let titleLabel = SyLabel(frame: CGRect(x: imgV.frame.maxX + 10, y: 15, width: cell.bounds.size.width - 70, height: 20), text: model.name, textColor: .lightGray, font: UIFont.systemFont(ofSize: 14), textAlignment: .left)
            cell.contentView.addSubview(titleLabel)
            
            //演唱者
            let singerLabel = SyLabel(frame: CGRect(x: titleLabel.frame.origin.x, y: titleLabel.frame.maxY + 5, width: titleLabel.bounds.size.width, height: 20), text: model.singer, textColor: titleLabel.textColor, font: UIFont.systemFont(ofSize: 10), textAlignment: .left)
            cell.contentView.addSubview(singerLabel)
            
            if SyAVPlayer.getSharedInstance().musicArray.count > SyAVPlayer.getSharedInstance().currentIndex{
                if SyAVPlayer.getSharedInstance().musicArray[SyAVPlayer.getSharedInstance().currentIndex].id == model.id && SyAVPlayer.getSharedInstance().musicArray[SyAVPlayer.getSharedInstance().currentIndex].category == self.useritem.id { //当前音频播放状态
                    if SyAVPlayer.getSharedInstance().isPlay {
                        imgV.startAnimating()
                        imgV.image = nil
                    }else{
                        imgV.stopAnimating()
                        imgV.image = #imageLiteral(resourceName: "item_bledevice_playing_01_icon")
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
