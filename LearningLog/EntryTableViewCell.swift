//
//  EntryTableViewCell.swift
//  LearningLog
//
//  Created by nonamer on 2018/12/14.
//  Copyright © 2018年 龙洪杰. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {
    
    //MARK: Propertties
    @IBOutlet weak var creationTimeLabel: UILabel!
    @IBOutlet weak var entryTextLable: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
