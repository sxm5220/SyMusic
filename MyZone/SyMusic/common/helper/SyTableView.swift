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
        self.separatorColor = UIColor.white
    }
    
    convenience init(array: Array<CGFloat>, _ style: UITableView.Style, _ dele: NSObject) {
        if array.count > 0 {
            let frame: CGRect = CGRect.init(x: array[0],
                                            y: array[1],
                                            width: array[2],
                                            height: array[3])
            self.init(frame: frame, style: style)
        }else{
            self.init(frame: CGRect.zero, style: style)
        }
        self.delegate = dele as? UITableViewDelegate
        self.dataSource = dele as? UITableViewDataSource
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
