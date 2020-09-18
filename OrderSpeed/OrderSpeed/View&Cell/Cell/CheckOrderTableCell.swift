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
//    var orderProduct: OrderProductModel? {
//        didSet {
//            if let item = self.orderProduct {
//                self.lblLink.text = item.link
//                self.lblName.text = item.name
//                self.lblSize.text = item.size
//                self.lblNumber.text = "\(item.number)"
//                let moneyYen = item.price * Double(item.number)
//                self.lblPriceCNY.text = Tools.convertCurrencyFromString(input: String(format: "%.2f", moneyYen)) + " ¥"
//                let moneyVND = ceil(moneyYen * Tools.TI_GIA_NDT)
//                self.lblPriceVND.text = Tools.convertCurrencyFromString(input: String(format: "%.0f", moneyVND)) + " VND\r\n(Tỉ giá: \(Tools.convertCurrencyFromString(input: "\(Tools.TI_GIA_NDT)")))"
//                self.lblNote.text = item.note
//            }
//        }
//    }
    
    var product: ProductModel? {
        didSet {
            if let item = self.product {
                self.lblLink.text = item.link
                self.lblName.text = item.name
                self.lblSize.text = item.option
                self.lblNumber.text = "\(item.amount)"
                let moneyYen = item.price * Double(item.amount)
                self.lblPriceCNY.text = Tools.convertCurrencyFromString(input: String(format: "%.2f", moneyYen)) + " ¥"
                let moneyVND = ceil(moneyYen * Tools.TI_GIA_NDT)
                self.lblPriceVND.text = Tools.convertCurrencyFromString(input: String(format: "%.0f", moneyVND)) + " VND\r\n(Tỉ giá: \(Tools.convertCurrencyFromString(input: "\(Tools.TI_GIA_NDT)")))"
                self.lblNote.text = item.note
                print("===> \(item.arrProductImages?.count)")
                DispatchQueue.main.async {
                    self.collectionImages.reloadData()
                }
            }
        }
    }
    
    var refStorage: StorageReference?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        heightCollectionOld = heightCollectionImages.constant
        print("======> heightCollectionOld : \(heightCollectionOld)")
        collectionImages.register(UINib(nibName: "ImageProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageProductCollectionViewCell")
        collectionImages.delegate = self
        collectionImages.dataSource = self
        
        lblLink.text = nil
        lblName.text = nil
        lblSize.text = nil
        lblNumber.text = nil
        lblPriceCNY.text = "¥"
        lblPriceVND.text = "đ"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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

extension CheckOrderTableCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.width / 3 - 5
        return CGSize(width: w, height: w)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if product != nil {
            if let arrImage = product?.images, arrImage.count > 0 {
                return arrImage.count
            } else if let arrImage = product?.arrProductImages, arrImage.count > 0 {
                return arrImage.count
            }
            return 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageProductCollectionViewCell", for: indexPath) as! ImageProductCollectionViewCell
        if let arrImage = product?.images, arrImage.count > indexPath.row, let ref = self.refStorage {
            let imageName = arrImage[indexPath.row]
            let reference = ref.child("Images/\(imageName)")
            cell.imgvProduct.sd_setImage(with: reference, placeholderImage: UIImage(named: ""))
        } else if let arrImage = product?.arrProductImages, arrImage.count > indexPath.row {
            let item = arrImage[indexPath.row]
            cell.imgvProduct.image = item.image
        }
//        if let imageName = product?.images?[indexPath.row], imageName.count > indexPath.row, let ref = self.refStorage {
//            let reference = ref.child("Images/\(imageName)")
//            cell.imgvProduct.sd_setImage(with: reference, placeholderImage: UIImage(named: ""))
//        } else if let item = product?.arrProductImages?[indexPath.row] {
//            cell.imgvProduct.image = item.image
//        }
        cell.imgvDefault.isHidden = true
        cell.btnDelete.isHidden = true
        return cell
    }
}
