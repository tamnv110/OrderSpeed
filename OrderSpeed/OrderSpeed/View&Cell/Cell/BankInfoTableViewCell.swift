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
    @IBOutlet weak var imgvIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func showInfo(_ item: BankInfoModel) {
        lblName.text = item.bankName
        lblOwner.text = item.ownerName
        lblBankNumber.text = item.accountNumber
        lblBranch.text = item.bankBranch
        if let url = URL(string: item.image) {
            imgvIcon.sd_setImage(with: url)
        }
    }
    
    @IBAction func eventChooseCopyBankNumber(_ sender: Any) {
        if let bankNumber = lblBankNumber.text {
            UIPasteboard.general.string = bankNumber
            NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_COPY_BANK_NUMBER"), object: bankNumber, userInfo: nil)
        }
    }
}
