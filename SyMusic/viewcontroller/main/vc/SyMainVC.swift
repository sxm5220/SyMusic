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

class SyMainVC: SyBaseVC {
    
    fileprivate var dataCourseArray: NSMutableArray = NSMutableArray()
    fileprivate let heightValue: CGFloat = 250.0
    fileprivate var itemWidth: CGFloat = (screenWidth() - 20 - 45) / 2
    let categoryArray = ["01","02","03"]
    let titleArray = ["周杰伦","薛之谦","Backstreet Boys"]
    let imgsArray = ["item_jz_icon","item_xjq_icon","item_BSBoys_icon"]
    
    fileprivate lazy var cycleView: SyCycleRollView = {
        var cycleView = SyCycleRollView(frame: CGRect(x: 0, y: 0, width: screenWidth() - 10, height: heightValue), localImageArray: [#imageLiteral(resourceName: "item_JayChou_icon"),#imageLiteral(resourceName: "item_JokerXue_icon"),#imageLiteral(resourceName: "item_BackstreetBoys_icon")])
        //设置代理，监听点击图片的事件
        cycleView.delegate = self
        return cycleView
    }()
    
    fileprivate lazy var headView: UIView = {
        var headView = UIView(frame: CGRect(x: 5, y: -90, width: screenWidth() - 10, height: heightValue))
        headView.backgroundColor = UIColor.white
        headView.layer.cornerRadius = 10
        headView.clipsToBounds = true
        headView.addSubview(self.cycleView)
        return headView
    }()
    
    fileprivate lazy var tableView: SyTableView = {
        let heightValue: CGFloat = screenHeight() - toolBarWithHeight() - navigationBarWithHeight() - self.headView.bounds.size.height
        
        var tableView = SyTableView(array: [10,self.headView.frame.maxY + 5,screenWidth() - 20,heightValue], .grouped, self)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .darkGray//rgbWithValue(r: 220, g: 220, b: 220, alpha: 1.0)
        tableView.separatorInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.musicDataSource(isRefresh: true)
        })
        tableView.mj_header?.beginRefreshing()
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        if self.cycleView.timer != nil {
            self.cycleView.goOnTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
        
        if self.cycleView.timer != nil {
            if self.cycleView.timer!.isValid {
                self.cycleView.pauseTimer()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.headView)
        self.view.addSubview(self.tableView)
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        let indexValue: Int = sender.view?.tag ?? -1
        if self.dataCourseArray.count > indexValue && indexValue != -1 {
            self.pushVC(index: indexValue)
        }
    }
    
    fileprivate func musicDataSource(isRefresh: Bool) {
        if isRefresh {
            self.dataCourseArray.removeAllObjects()
        }
        
        for i in 0..<titleArray.count {
            let model = SyMusicsModel()
            model.category = categoryArray[i]
            model.name = titleArray[i]
            model.icon = imgsArray[i]
            self.dataCourseArray.add(model)
        }
        self.loadDataComplete()
    }
    
    func loadDataComplete() {
        DispatchQueue.main.async {
            /*if self.imgsArray.count > 0 {
                var modelArray = [SyCycleViewImageModel]()
                var model: SyCycleViewImageModel
                for item in self.imgsArray {
                    model = SyCycleViewImageModel(imageUrlString: item)
                    modelArray.append(model)
                }
                self.cycleView.imageModelArray = modelArray
                self.cycleView.commonInit()
            }*/
            self.tableView.reloadData()
            self.tableView.mj_header?.endRefreshing()
        }
    }
    
    fileprivate func pushVC(index: Int) {
        let item = self.dataCourseArray[index] as? SyMusicsModel
        let vc = SyMainDetailVC()
        vc.title = item?.name
        vc.categoryId = item?.category
        vc.headImageView.image = UIImage.init(named: item?.icon ?? "")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension SyMainVC: SyCycleRollViewDelegate {
    
    func tapImage(_ cycleView: SyCycleRollView, currentImage: UIImage?, currentIndex: Int) {
        if self.dataCourseArray.count > currentIndex{
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
        if self.dataCourseArray.count > 0 {
            return (self.dataCourseArray.count + 1) / 2
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
        if self.dataCourseArray.count > selectRow {
            let model = self.dataCourseArray[selectRow] as? SyMusicsModel
            self.cellContentView(cell: cell, model: model, index: selectRow, isSecond: false)
            if self.dataCourseArray.count > (selectRow + 1) {
                let model = self.dataCourseArray[selectRow + 1] as? SyMusicsModel
                self.cellContentView(cell: cell, model: model, index: selectRow + 1, isSecond: true)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate func cellContentView(cell: UITableViewCell, model: SyMusicsModel?, index: Int, isSecond: Bool) {
        //头像
        let headerImageView = UIImageView(frame: CGRect(x: 10 + (isSecond ? ((screenWidth() - 10 * 3) / 2 + 10) : 0), y: 10, width: itemWidth, height: itemWidth))
        headerImageView.layer.cornerRadius = 10
        headerImageView.isUserInteractionEnabled = true
        headerImageView.clipsToBounds = true
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.image = UIImage(named: model?.icon ?? "")
        headerImageView.tag = index
        headerImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:))))
        //headerImageView.image =
        //headerImageView.sd_setImage(with: URL(string: model.headUrl), placeholderImage: #imageLiteral(resourceName: "item_color_5_icon"))
        cell.contentView.addSubview(headerImageView)
        
        //名称
        let titleLabel = SyLabel(frame: CGRect(x: 0, y: headerImageView.frame.maxY + 8, width: headerImageView.bounds.size.width, height: 20), text: model?.name ?? "", textColor: .white, font: UIFont.boldSystemFont(ofSize: 20), textAlignment: .center)
        titleLabel.center.x = headerImageView.center.x
        cell.contentView.addSubview(titleLabel)
    }
}
