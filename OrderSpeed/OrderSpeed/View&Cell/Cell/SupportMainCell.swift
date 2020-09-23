//
//  SupportMainCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/5/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

extension Collection {
    
    func chunked(by distance: Int) -> [[Element]] {
        var result: [[Element]] = []
        var batch: [Element] = []
        
        for element in self {
            batch.append(element)
            
            if batch.count == distance {
                result.append(batch)
                batch = []
            }
        }
        
        if !batch.isEmpty {
            result.append(batch)
        }
        
        return result
    }
    
}

class SupportMainCell: UITableViewCell {
    private let TAG = "SupportMainCell"
    @IBOutlet weak var collectionSupport: UICollectionView!
    @IBOutlet weak var pageSupport: UIPageControl!
    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var lblThongBao: UILabel!
    var arrResultChunked:[[Any]]?
    
    var arrInfo:[Any]? {
        didSet {
            if let _arrInfo = arrInfo {
                if _arrInfo.count == 0 {
                    loadingView.isHidden = true
                    lblThongBao.text = "Không tìm thấy danh sách."
                } else {
                    var pageItems = 3
                    if typeShow == 1 {
                        pageItems = 2
                    } else if typeShow == 3 {
                        pageItems = 1
                    }
                    let result = chunkArray(s: _arrInfo, splitSize: pageItems)
                    if self.arrResultChunked == nil {
                        self.arrResultChunked = [[Any]]()
                    }
                    print("==========> result.count : \(result.count)")
                    self.arrResultChunked?.append(contentsOf: result)
                    collectionSupport.reloadData()
                    pageSupport.numberOfPages = result.count
                }
            } else {
                loadingView.isHidden = false
            }
        }
    }
    var typeShow = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageSupport.numberOfPages = 0
        collectionSupport.register(UINib(nibName: "SupportCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SupportCollectionCell")
        collectionSupport.register(UINib(nibName: "InfomationCollectionCell", bundle: nil), forCellWithReuseIdentifier: "InfomationCollectionCell")
        collectionSupport.delegate = self
        collectionSupport.dataSource = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pageSupport.subviews.forEach { (subView) in
            subView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
    }
    
    func chunkArray<T>(s: [T], splitSize: Int) -> [[T]] {
        if s.count <= splitSize {
            return [s]
        } else {
            return [Array<T>(s[0..<splitSize])] + chunkArray(s: Array<T>(s[splitSize..<s.count]), splitSize: splitSize)
        }
    }
}

extension SupportMainCell: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrResultChunked?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageSupport.currentPage = indexPath.row
        if let cell = cell as? SupportCollectionCell {
            if let _arrInfo = arrResultChunked?[indexPath.row] {
                cell.arrInfo = _arrInfo
            }
        } else if let cell = cell as? InfomationCollectionCell {
            if let _arrInfo = arrResultChunked?[indexPath.row], let item = _arrInfo.first as? InformationModel{
                cell.showInfo(item)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if typeShow == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfomationCollectionCell", for: indexPath) as! InfomationCollectionCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SupportCollectionCell", for: indexPath) as! SupportCollectionCell
        cell.typeShow = typeShow
        return cell
    }
}
