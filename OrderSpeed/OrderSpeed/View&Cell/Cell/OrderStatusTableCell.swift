//
//  OrderStatusTableCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/18/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class OrderStatusTableCell: UITableViewCell {

    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTime.text = nil
    }
    
    func showInfo(_ item: OrderStatusModel) {
        lblStatus.text = item.name
        lblContent.text = item.message
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: item.createAt) {
            formatter.dateFormat = "HH:mm dd/MM/yyyy"
            lblTime.text = formatter.string(from: date)
        }
    }
    
    func showInfoSupport(_ item: RequestSupportModel) {
        lblStatus.text = item.title
        lblContent.text = item.content
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: item.createAt) {
            formatter.dateFormat = "HH:mm dd/MM/yyyy"
            lblTime.text = formatter.string(from: date)
        }
    }
}
