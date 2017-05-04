//
//  FavoStockCell.swift
//  StockSearch
//
//  Created by 杜袁茵 on 5/3/16.
//  Copyright © 2016 Yuanyin Du. All rights reserved.
//

import UIKit

class FavoStockCell: UITableViewCell {

    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var changePercent: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var marketCap: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
