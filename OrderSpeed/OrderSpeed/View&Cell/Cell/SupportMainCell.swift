//
//  SupportMainCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/5/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class SupportMainCell: UITableViewCell {

    @IBOutlet weak var collectionSupport: UICollectionView!
    @IBOutlet weak var pageSupport: UIPageControl!
    var typeShow = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionSupport.register(UINib(nibName: "SupportCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SupportCollectionCell")
        collectionSupport.delegate = self
        collectionSupport.dataSource = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pageSupport.subviews.forEach { (subView) in
            subView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
    }
    
}

extension SupportMainCell: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageSupport.currentPage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SupportCollectionCell", for: indexPath) as! SupportCollectionCell
        cell.typeShow = typeShow
        return cell
    }
}
