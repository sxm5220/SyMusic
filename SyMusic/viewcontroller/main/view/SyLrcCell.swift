//
//  SyLrcCell.swift
//  SyMusic
//
//  Created by sxm on 2020/5/26.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit

class SyLrcCell: UITableViewCell {

    @IBOutlet weak var lrcLabel: SyLrcLabel!
    
    var progress: CGFloat = 0 {
        didSet {
            lrcLabel.radio = progress
        }
    }
    
    var lrcContent: String = "" {
        didSet {
            lrcLabel.text = lrcContent
        }
    }
    
    class func cellWithTableView(_ tableView: UITableView) -> SyLrcCell {
        let cellID = "lrc"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? SyLrcCell
        if cell ==  nil {
            cell = Bundle.main.loadNibNamed("SyLrcCell", owner: nil, options: nil)?.first as? SyLrcCell
            
        }
        return cell!
    }

}
