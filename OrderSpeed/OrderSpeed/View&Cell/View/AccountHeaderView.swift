//
//  AccountHeaderView.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/21/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseUI
class AccountHeaderView: UIView {

    @IBOutlet weak var imgvAvatar: UIImageView!
    @IBOutlet weak var btnCamera: UIButton!
    
    class func instanceFromNib() -> AccountHeaderView {
        return UINib(nibName: "AccountHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! AccountHeaderView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnCamera.layer.borderColor = UIColor.lightGray.cgColor
        imgvAvatar.layer.borderColor = UIColor.white.cgColor
    }

}
