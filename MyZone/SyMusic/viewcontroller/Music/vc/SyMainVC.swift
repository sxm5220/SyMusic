//
//  SyMainVC.swift
//  SyMusic
//
//  Created by sxm on 2020/5/13.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import UIKit
import Lottie
import MJRefresh
import SafariServices

struct userItem {
    let id,name,icon: String
    let star: MusicStar
}

class SyMainVC: SyBaseVC {
    final let heightValue: CGFloat = 250.0
    final var itemWidth: CGFloat = (screenWidth - 20 - 45) / 2
    let userItems = [userItem(id: "01", name: "周杰伦", icon: "item_jz_icon",star: .JayChou),
                 userItem(id: "02", name: "薛之谦", icon: "item_xjq_icon",star: .JokerXue),
                 userItem(id: "03", name: "Backstreet Boys", icon: "item_BSBoys_icon",star: .BackstreetBoys),
                 userItem(id: "04", name: "王力宏", icon: "item_lh_icon", star: .LeehomWang)]
    
    /*fileprivate lazy var cycleView: SyCycleRollView = {
        var cycleView = SyCycleRollView(frame: CGRect(x: 0, y: 0, width: screenWidth - 10, height: heightValue), localImageArray: [])
        //设置代理，监听点击图片的事件
        cycleView.delegate = self
        return cycleView
    }()
    
    fileprivate lazy var headView: UIView = {
        var headView = UIView(frame: CGRect(x: 5, y: -90, width: screenWidth - 10, height: heightValue))
        headView.backgroundColor = UIColor.white
        headView.layer.cornerRadius = 10
        headView.clipsToBounds = true
        headView.addSubview(self.cycleView)
        return headView
    }()*/
    
    fileprivate lazy var tableView: SyTableView = {
        var tableView = SyTableView(style: .grouped, delegate: self)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .darkGray
        tableView.separatorInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.loadDataComplete()
        })
        tableView.mj_header?.beginRefreshing()
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    
    /*override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
//        if self.cycleView.timer != nil {
//            self.cycleView.goOnTimer()
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
        
//        if self.cycleView.timer != nil {
//            if self.cycleView.timer!.isValid {
//                self.cycleView.pauseTimer()
//            }
//        }
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = strCommon(key: "sy_music_title")
//        self.view.addSubview(self.headView)
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        let indexValue: Int = sender.view?.tag ?? -1
        if self.userItems.count > indexValue && indexValue != -1 {
            self.pushVC(index: indexValue)
        }
    }
    
    func loadDataComplete() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.mj_header?.endRefreshing()
        }
    }
    
    fileprivate func pushVC(index: Int) {
        let vc = SyAlbumListVC()
        vc.useritem = self.userItems[index]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension SyMainVC: SyCycleRollViewDelegate {
    
    func tapImage(_ cycleView: SyCycleRollView, currentImage: UIImage?, currentIndex: Int) {
        if self.userItems.count > currentIndex{
            self.pushVC(index: currentIndex)
        }
    }
}

extension SyMainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.userItems.count > 0 {
            return (self.userItems.count + 1) / 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemWidth + 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        let selectRow = indexPath.row * 2
        if self.userItems.count > selectRow {
            self.cellContentView(cell: cell, item: self.userItems[selectRow], index: selectRow, isSecond: false)
            if self.userItems.count > (selectRow + 1) {
                self.cellContentView(cell: cell, item: self.userItems[selectRow + 1], index: selectRow + 1, isSecond: true)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate func cellContentView(cell: UITableViewCell, item: userItem, index: Int, isSecond: Bool) {
        
        //头像
        let headerImageView = UIImageView()
        headerImageView.layer.cornerRadius = 10
        headerImageView.isUserInteractionEnabled = true
        headerImageView.clipsToBounds = true
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.image = UIImage(named: item.icon)
        headerImageView.tag = index
        headerImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:))))
        cell.contentView.addSubview(headerImageView)
        
        let rectX = isSecond ? ((screenWidth - 10 * 3) / 2 + 20) : 10
        
        headerImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(rectX+10)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(itemWidth)
        }
        //名称
        let titleLabel = SyLabel(text: item.name, textColor: .white, font: UIFont.boldSystemFont(ofSize: 20), textAlignment: .center)
        cell.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(rectX+10)
            make.top.equalToSuperview().offset(itemWidth + 20)
            make.width.equalTo(itemWidth)
            make.height.equalTo(20)
        }
    }
}
