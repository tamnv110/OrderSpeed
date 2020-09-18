//
//  SupportTableViewCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/4/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class SupportTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var btnPhone: UIButton!
    @IBOutlet weak var btnMessenger: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func showInfo(_ item: SupportModel) {
        lblTitle.text = item.name
        lblPhone.text = item.phone
    }
    
}
