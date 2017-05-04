//
//  NewsCell.swift
//  StockSearch
//
//  Created by 杜袁茵 on 5/2/16.
//  Copyright © 2016 Yuanyin Du. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {

    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDescription: UILabel!
    @IBOutlet weak var newsPublisher: UILabel!
    @IBOutlet weak var newsDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
