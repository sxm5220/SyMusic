//
//  SyAlbumListVC.swift
//  SyMusic
//
//  Created by sxm on 2022/3/18.
//  Copyright © 2022 wwsq. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh

class SyAlbumListVC: SyBaseVC {
    final var itemWidth: CGFloat = 110
    public var useritem: userItem!
    private var composerId: String = ""
    private var dataCourseArray: [SyAlbumItem] = [SyAlbumItem]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    fileprivate lazy var tableView: SyTableView = {
       let heightValue: CGFloat = screenHeight() - toolBarWithHeight() - navigationBarWithHeight() - 5
        var tableView = SyTableView(array: [10, 5,screenWidth() - 20,heightValue], .grouped, self)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.separatorColor = .darkGray//rgbWithValue(r: 220, g: 220, b: 220, alpha: 1.0)
        tableView.separatorInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.albumListDataSource(isRefresh: true)
        })
        tableView.mj_header?.beginRefreshing()
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isBackBar = true
        self.title = strCommon(key: "sy_album")
        self.view.addSubview(self.tableView)
    }
    
    fileprivate func albumListDataSource(isRefresh: Bool) {
        SyMusicPlayerManager.dataSource(star: self.useritem.star) { item in
            guard let item = item else { return }
            let albumItems = item.albums
            self.dataCourseArray = albumItems
            self.composerId = item.composerId
            self.loadDataComplete()
        }
    }
    
    func loadDataComplete() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.mj_header?.endRefreshing()
        }
    }
}

extension SyAlbumListVC: UITableViewDelegate, UITableViewDataSource {
    
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
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.accessoryView = UIImageView(image: sfImage(name: "chevron.forward",15,nil,.lightGray))
        if self.dataCourseArray.count > indexPath.row {
            let musicItem = self.dataCourseArray[indexPath.row]
            self.cellContentView(cell: cell, item: musicItem, index: indexPath.row, isSecond: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.dataCourseArray.count > indexPath.row {
            let albumItem = self.dataCourseArray[indexPath.row]
            let vc = SyAlbumMusicListVC()
            vc.albumItem = albumItem
            vc.useritem = self.useritem
            vc.composerId = self.composerId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    fileprivate func cellContentView(cell: UITableViewCell, item: SyAlbumItem, index: Int, isSecond: Bool) {
        
        //专辑图
        let albumImageView = UIImageView(frame: CGRect(x: 20, y: 20, width: itemWidth, height: itemWidth))
        albumImageView.layer.cornerRadius = 10
        albumImageView.clipsToBounds = true
        albumImageView.contentMode = .scaleAspectFill
        albumImageView.image = UIImage(named: item.albumImage)
        cell.contentView.addSubview(albumImageView)
        
        //专辑名称
        let albumNameLab = SyMarqueeLabel(frame: CGRect(x: albumImageView.frame.maxX + 20, y: albumImageView.frame.minY + 15, width: cell.bounds.size.width - albumImageView.bounds.size.width - 50, height: 20), text: item.albumName, textColor: .white, font: UIFont.boldSystemFont(ofSize: 18), textAlignment: .left)
        cell.contentView.addSubview(albumNameLab)
        
        //发行公司
        let productionCompanyLab = SyMarqueeLabel(frame: CGRect(x: albumNameLab.frame.origin.x, y: albumNameLab.frame.maxY + 10, width: albumNameLab.bounds.size.width, height: 20), text: item.productionCompany, textColor: .white, font: UIFont.systemFont(ofSize: 15), textAlignment: .left)
        cell.contentView.addSubview(productionCompanyLab)
        
        //发行时间
        let issueDateLab = SyMarqueeLabel(frame: CGRect(x: productionCompanyLab.frame.origin.x, y: productionCompanyLab.frame.maxY + 10, width: productionCompanyLab.bounds.size.width, height: 20), text: item.issueDate, textColor: .white, font: productionCompanyLab.font, textAlignment: .left)
        cell.contentView.addSubview(issueDateLab)
        
    }
}
