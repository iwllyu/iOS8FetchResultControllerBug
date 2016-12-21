//
//  ItemCell.swift
//  iOS8FetchResultControllerBug
//
//  Created by Yu, William on 12/9/16.
//  Copyright © 2016 iwllyu. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var isReadLabel: UILabel!
    
    func configureCell(item: Item?) {
        guard let item = item else {
            NSLog("item was nil")
            return
        }
        
        titleLabel.text = item.title
        messageLabel.text = item.message
        isReadLabel.text = String(item.isRead)
    }


}
