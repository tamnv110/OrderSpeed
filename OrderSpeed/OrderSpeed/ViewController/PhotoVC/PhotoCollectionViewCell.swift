//
//  PhotoCollectionViewCell.swift
//  TestPhoto
//
//  Created by Nguyen Van Tam on 11/29/19.
//  Copyright © 2019 TamNV. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewSelected: UIView!
//    @IBOutlet weak var imgvSelected: UIImageView!
    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var imgvThumb: UIImageView!
    var representedAssetIdentifier: String!
    
    var thumbnailImage:UIImage! {
        didSet {
            imgvThumb.image = self.thumbnailImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        viewSelected.layer.cornerRadius = viewSelected.frame.height / 2
//        viewSelected.layer.borderWidth = 1
//        viewSelected.layer.borderColor = UIColor.white.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        viewSelected.layer.cornerRadius = viewSelected.frame.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgvThumb.image = nil
    }
}
