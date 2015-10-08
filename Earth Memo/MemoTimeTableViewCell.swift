//
//  MemoTimeTableViewCell.swift
//  Earth Memo
//
//  Created by Yuning Jin on 7/24/15.
//  Copyright (c) 2015 Noctiz. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class MemoTimeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activeAtLabel: UILabel!
    @IBOutlet weak var dayAway: UILabel!
    @IBOutlet weak var star: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
