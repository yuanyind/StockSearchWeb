//
//  DetailWithPicCell.swift
//  StockSearch
//
//  Created by 杜袁茵 on 5/4/16.
//  Copyright © 2016 Yuanyin Du. All rights reserved.
//

import UIKit

class DetailWithPicCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var secondCol: UILabel!
    @IBOutlet weak var firstCol: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
