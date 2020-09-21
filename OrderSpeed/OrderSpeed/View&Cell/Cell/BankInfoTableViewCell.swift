//
//  BankInfoTableViewCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/5/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class BankInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var lblBankNumber: UILabel!
    @IBOutlet weak var lblBranch: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func showInfo(_ item: BankInfoModel) {
        lblName.text = item.bankName
        lblOwner.text = item.ownerName
        lblBankNumber.text = item.accountNumber
        lblBranch.text = item.bankBranch
    }
    
}
