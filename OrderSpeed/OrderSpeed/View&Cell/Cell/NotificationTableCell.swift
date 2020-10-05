//
//  NotificationTableCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 10/1/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class NotificationTableCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func showInfo(_ item: NotificationModel) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let dateItem = formatter.date(from: item.createAt) {
            formatter.dateFormat = "HH:mm dd/MM/yyyy"
            lblTime.text = formatter.string(from: dateItem)
        } else {
            lblTime.text = nil
        }
        lblTitle.text = item.title
        lblContent.text = item.message
    }
    
}
