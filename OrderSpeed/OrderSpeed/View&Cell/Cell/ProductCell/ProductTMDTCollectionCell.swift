//
//  ProductTMDTCollectionCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 10/26/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import SDWebImage
class ProductTMDTCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imgvThumb: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func showInfor(_ item: ProductModel) {
        let link = item.images?.first ?? ""
        imgvThumb.sd_setImage(with: URL(string: link), placeholderImage: UIImage(named: "test_product"))
        lblName.text = item.name
        lblPrice.text = Tools.convertCurrencyFromString(input: "\(item.price)").replacingOccurrences(of: ".0", with: "")
    }
}
