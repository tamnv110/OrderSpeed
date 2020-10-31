//
//  HomeOptionCollectionViewCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/4/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class HomeOptionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgvIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgvIcon.layer.cornerRadius = 12
    }

    func showInfo(_ item: ProductSiteModel) {
        lblName.text = item.name
        if item.link.isEmpty {
            imgvIcon.image = item.image.isEmpty ? UIImage(named: "icon_tao_gd") : UIImage(named: item.image)
        } else {
            imgvIcon.sd_setImage(with: URL(string: item.image), placeholderImage: UIImage(named: ""))
        }
    }
    
}
