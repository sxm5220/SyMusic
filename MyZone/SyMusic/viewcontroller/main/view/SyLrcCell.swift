//
//  SyLrcCell.swift
//  SyMusic
//
//  Created by sxm on 2020/5/26.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit

class SyLrcCell: UITableViewCell {
    
    class var identifier: String {
        return String(describing: self)
    }
    
    lazy var lrcLabel: SyLrcLabel = {
        let lab = SyLrcLabel(frame: CGRect(x: 0, y: 0, width: screenWidth(), height: 20))
        lab.textColor = .lightGray
        lab.textAlignment = .center
        return lab
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.addSubview(self.lrcLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func cellWithTableView(_ tableView: UITableView) -> SyLrcCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SyLrcCell.identifier) as? SyLrcCell
        if cell == nil {
            cell = SyLrcCell.init(style: .default, reuseIdentifier: SyLrcCell.identifier)
        }
        return cell!
    }
}
