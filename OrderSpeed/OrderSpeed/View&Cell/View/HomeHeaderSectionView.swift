//
//  HomeHeaderSectionView.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/5/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class HomeHeaderSectionView: UIView {

    @IBOutlet weak var imgvIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnOption: UIButton!
    
    class func instanceFromNib() -> HomeHeaderSectionView {
        return UINib(nibName: "HomeHeaderSectionView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! HomeHeaderSectionView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnOption.isHidden = true
    }
}
