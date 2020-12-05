//
//  CheckOrderTableCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/9/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import FirebaseStorage

class CheckOrderTableCell: UITableViewCell {
    private let TAG = "CheckOrderTableCell"
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLink: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblPriceCNY: UILabel!
    @IBOutlet weak var lblPriceVND: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var collectionImages: UICollectionView!
    @IBOutlet weak var heightCollectionImages: NSLayoutConstraint!
    @IBOutlet weak var btnEdit: UIButton!
    var heightCollectionOld: CGFloat = 0
    
    var product: ProductModel? {
        didSet {
            if let item = self.product {
                self.arrImages.removeAll()
                self.lblLink.text = item.link
                self.lblName.text = item.name
                if item.name.isEmpty {
                    self.lblName.text = " "
                }
                self.lblSize.text = item.option
                self.lblNumber.text = "\(item.amount)"
                let moneyYen = item.price * Double(item.amount)
                self.lblPriceCNY.text = Tools.convertCurrencyFromString(input: String(format: "%.2f", moneyYen)) + " \(Tools.NDT_LABEL)"
                let moneyVND = ceil(moneyYen * Tools.TI_GIA_NDT)
                self.lblPriceVND.isHidden = Tools.NDT_LABEL.isEmpty
                self.lblLink.isHidden = Tools.NDT_LABEL.isEmpty
                
                self.lblPriceVND.text = Tools.NDT_LABEL.isEmpty ? "" : Tools.convertCurrencyFromString(input: String(format: "%.0f", moneyVND)) + " VND\r\n(Tỉ giá: \(Tools.convertCurrencyFromString(input: "\(Tools.TI_GIA_NDT)")))"
                self.lblNote.text = item.note
                self.lblNote.isHidden = Tools.NDT_LABEL.isEmpty
                if let imagesLocal = item.arrProductImages {
                    let result = imagesLocal.map { (item) -> (Int, String?, ItemImageSelect?) in
                        return (0, nil, item)
                    }
                    self.arrImages.append(contentsOf: result)
                }
                if let imagesServer = item.images {
                    let result = imagesServer.map{ (item) -> (Int, String?, ItemImageSelect?) in
                        return (1, item, nil)
                    }
                    self.arrImages.append(contentsOf: result)
                }
                DispatchQueue.main.async {
                    self.collectionImages.reloadData()
                }
            }
        }
    }
    
    var refStorage: StorageReference?
    var arrImages = [(Int, String?, ItemImageSelect?)]()
    var isShadow = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        heightCollectionOld = heightCollectionImages.constant
        collectionImages.register(UINib(nibName: "ImageProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageProductCollectionViewCell")
        collectionImages.delegate = self
        collectionImages.dataSource = self
        
        lblLink.text = nil
        lblName.text = nil
        lblSize.text = nil
        lblNumber.text = nil
        lblPriceCNY.text = Tools.NDT_LABEL
        lblPriceVND.text = "đ"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isShadow {
            DispatchQueue.main.async {
                self.viewShadow.layer.shadowColor = UIColor.lightGray.cgColor
                self.viewShadow.layer.shadowOffset = CGSize(width: 0, height: 1)
                self.viewShadow.layer.shadowOpacity = 0.5
                self.viewShadow.layer.shadowRadius = 3
                self.viewShadow.layer.masksToBounds = false
                self.viewShadow.layer.shadowPath = UIBezierPath(roundedRect: self.viewShadow.bounds, cornerRadius: 16).cgPath
                self.viewShadow.layer.shouldRasterize = true
            }
        }
    }
}

extension CheckOrderTableCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.width / 3 - 5
        return CGSize(width: w, height: w)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageProductCollectionViewCell", for: indexPath) as! ImageProductCollectionViewCell
        let item = arrImages[indexPath.row]
        if item.0 == 0 {
            cell.imgvProduct.image = item.2?.image
        } else if let imageName = item.1, let ref = self.refStorage {
             let reference = ref.child("Images/\(imageName)")
            cell.imgvProduct.sd_setImage(with: reference, placeholderImage: nil)
        }
//        if let arrImage = product?.images, arrImage.count > indexPath.row, let ref = self.refStorage {
//            let imageName = arrImage[indexPath.row]
//            let reference = ref.child("Images/\(imageName)")
//            cell.imgvProduct.sd_setImage(with: reference, placeholderImage: nil)
//        } else if let arrImage = product?.arrProductImages, arrImage.count > indexPath.row {
//            let item = arrImage[indexPath.row]
//            cell.imgvProduct.image = item.image
//        }
        cell.imgvDefault.isHidden = true
        cell.btnDelete.isHidden = true
        return cell
    }
}
