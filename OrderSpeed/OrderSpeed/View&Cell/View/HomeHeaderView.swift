//
//  HomeHeaderView.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/4/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class HomeHeaderView: UIView {

    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewShadow: UIView!
    
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#DC7942").cgColor, Tools.hexStringToUIColor(hex: "#F8AD25").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0.8)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.8)
        return gradientLayer
    }()
    
    var isDropShadow = false
    
    class func instanceFromNib() -> HomeHeaderView {
        return UINib(nibName: "HomeHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! HomeHeaderView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewSearch.layer.insertSublayer(gradientLayer, below: self.tfSearch.layer)
        
        tfSearch.layer.borderColor = UIColor.clear.cgColor
        tfSearch.layer.cornerRadius = 12
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 44))
        let imgvView = UIImageView(image: UIImage(named: "mangnifyingglass"))
        imgvView.contentMode = .scaleAspectFill
        imgvView.frame = CGRect(x: 8, y: 13, width: 18, height: 18)
        leftView.addSubview(imgvView)
        tfSearch.leftView = leftView
        tfSearch.leftViewMode = .always
        
        collectionView.register(UINib(nibName: "HomeOptionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeOptionCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDropShadow {
            isDropShadow = true
            gradientLayer.frame = self.viewSearch.bounds
            
            self.viewSearch.clipsToBounds = true
            self.viewSearch.layer.cornerRadius = 16
            
            viewShadow.layer.shadowColor = Tools.hexStringToUIColor(hex: "#DC7942").cgColor
            viewShadow.layer.shadowOffset = CGSize(width: 0, height: 3)
            viewShadow.layer.shadowOpacity = 1
            viewShadow.layer.shadowRadius = 8
            viewShadow.layer.masksToBounds = false
            viewShadow.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 5, y: 5, width: viewShadow.bounds.width - 5, height: viewShadow.bounds.height - 5), cornerRadius: viewShadow.layer.shadowRadius).cgPath
            viewShadow.layer.shouldRasterize = true
        }
    }
}

extension HomeHeaderView: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = collectionView.frame.height
        return CGSize(width: h * 0.77, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeOptionCollectionViewCell", for: indexPath) as! HomeOptionCollectionViewCell
        return cell
    }
    
    
}
