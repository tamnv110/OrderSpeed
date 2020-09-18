//
//  ImageProductCollectionViewCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/8/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseUI
class ImageProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgvProduct: UIImageView!
    @IBOutlet weak var imgvDefault: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imgvProduct.image = nil
    }
}
