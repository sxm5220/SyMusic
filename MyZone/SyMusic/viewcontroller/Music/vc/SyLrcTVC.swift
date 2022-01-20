//
//  SyLrcTVC.swift
//  SyMusic
//
//  Created by sxm on 2020/5/26.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit

class SyLrcTVC: UITableViewController {

    var progress: CGFloat = 0 {
        didSet {
            let cell = tableView.cellForRow(at: IndexPath(row: scrollRow, section: 0)) as? SyLrcCell
            cell?.lrcLabel.radio = progress
        }
    }
    
    var scrollRow = -1 {
        didSet {
            if scrollRow == oldValue { return }
            tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: UITableView.RowAnimation.fade)
            tableView.scrollToRow(at: IndexPath(row: scrollRow, section: 0), at: UITableView.ScrollPosition.middle, animated: true)
        }
    }
    
    var lrcMs: [SyLrcItem] = [SyLrcItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: tableView.frame.size.height * 0.5, left: 0, bottom: tableView.frame.size.height * 0.5, right: 0)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lrcMs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SyLrcCell.cellWithTableView(tableView)
        cell.lrcLabel.radio = indexPath.row == scrollRow ? progress : 0
        cell.lrcLabel.text = lrcMs[indexPath.row].lrcContent
        return cell
    }
}

