//
//  WalletTransactionTableCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 21/12/2020.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class WalletTransactionTableCell: UITableViewCell {

    @IBOutlet weak var lblMoney: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func showInfo(_ item: TransactionModel) {
        if item.type == 0 || item.type == 3 {
            lblMoney.text = "+ \(Tools.convertCurrencyFromString(input: Tools.convertCurrencyFromString(input: String(format: "%.0f", item.money))))"
        } else {
            lblMoney.text = "- \(Tools.convertCurrencyFromString(input: Tools.convertCurrencyFromString(input: String(format: "%.0f", item.money))))"
        }
        lblContent.text = item.content
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: item.updateAt) {
            formatter.dateFormat = "HH:mm dd/MM/yyyy"
            lblDate.text = formatter.string(from: date)
        } else {
            lblDate.text = nil
        }
    }
    
}
