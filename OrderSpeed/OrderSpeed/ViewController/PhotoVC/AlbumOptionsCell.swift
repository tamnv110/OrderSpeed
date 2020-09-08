//
//  AlbumOptionsCell.swift
//  TestPhoto
//
//  Created by Tâm Nguyễn on 12/18/19.
//  Copyright © 2019 TamNV. All rights reserved.
//

import UIKit

class AlbumOptionsCell: UITableViewCell {

    @IBOutlet weak var imgvThumb: UIImageView!
    @IBOutlet weak var lblAlbumName: UILabel!
    @IBOutlet weak var lblPhotosCount: UILabel!
    
    var thumbnailImage:UIImage! {
        didSet {
            imgvThumb.image = self.thumbnailImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblAlbumName.text = ""
        lblPhotosCount.text = ""
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imgvThumb.image = nil
    }
    
}
