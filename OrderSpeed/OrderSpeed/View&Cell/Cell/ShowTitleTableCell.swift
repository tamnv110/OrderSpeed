//
//  ShowTitleTableCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/9/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class ShowTitleTableCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var leadingTitle: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupLeadingTitle(_ space: CGFloat) {
        leadingTitle.constant = space
    }
    
}
