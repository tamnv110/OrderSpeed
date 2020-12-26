//
//  WalletHeaderView.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 21/12/2020.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class WalletHeaderView: UIView {

    class func instanceFromNib() -> WalletHeaderView {
        return UINib(nibName: "WalletHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! WalletHeaderView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
