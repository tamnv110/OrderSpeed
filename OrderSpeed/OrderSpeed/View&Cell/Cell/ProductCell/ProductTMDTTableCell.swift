//
//  ProductTMDTTableCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 10/26/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class ProductTMDTTableCell: UITableViewCell {

    @IBOutlet weak var collectionProduct: UICollectionView!
    var arrProduct = [ProductModel]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionProduct.reloadData()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionProduct.delegate = self
        collectionProduct.dataSource = self
        collectionProduct.register(UINib(nibName: "ProductTMDTCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ProductTMDTCollectionCell")
    }  
}

extension ProductTMDTTableCell: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.width / 2 - 16
        return CGSize(width: w, height: w * 1.54)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrProduct.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductTMDTCollectionCell", for: indexPath) as! ProductTMDTCollectionCell
        cell.showInfor(arrProduct[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = arrProduct[indexPath.row]
        NotificationCenter.default.post(name: NSNotification.Name("CLICK_PRODUCT_REAL"), object: item, userInfo: nil)
    }
}
