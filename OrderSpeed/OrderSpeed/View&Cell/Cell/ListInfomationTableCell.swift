//
//  ListInfomationTableCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 10/5/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class ListInfomationTableCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func showInfo(_ item: InformationModel) {
        lblTitle.text = item.title
        lblDesc.text = item.desc
    }
}
