//
//  SyTableView.swift
//  SyMusic
//
//  Created by sxm on 2020/5/14.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import UIKit

class SyTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.backgroundColor = UIColor.clear
        self.estimatedRowHeight = 0
        self.estimatedSectionHeaderHeight = 0
        self.estimatedSectionFooterHeight = 0
        self.separatorColor = .white
    }
    
    convenience init(style: UITableView.Style, delegate: NSObject) {
        self.init(frame: CGRect.zero, style: style)
        self.delegate = delegate as? UITableViewDelegate
        self.dataSource = delegate as? UITableViewDataSource
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
