//
//  InfomationCollectionCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/22/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class InfomationCollectionCell: UICollectionViewCell {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnMore: UIButton!

    lazy var gradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#BD3A52").cgColor, Tools.hexStringToUIColor(hex: "#FED182").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }()
    var typeInfo: NewsType = .news
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewTitle.layer.insertSublayer(gradient, below: lblType.layer)
    }
    
    func showInfo(_ item: InformationModel) {
        if item.type == 1 {
            typeInfo = .news
            lblType.text = "TIN TỨC"
        } else if item.type == 2 {
            typeInfo = .guide
            lblType.text = "HƯỚNG DẪN"
        } else if item.type == 3 {
            typeInfo = .notification
            lblType.text = "THÔNG BÁO"
        }
        lblTitle.text = item.title
        lblDesc.text = item.desc
        if let colorStart = item.colorStart, let colorEnd = item.colorEnd {
            gradient.colors = [colorStart.cgColor, colorEnd.cgColor]
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.gradient.frame = self.viewTitle.bounds
            self.viewMain.layer.shadowColor = UIColor.lightGray.cgColor
            self.viewMain.layer.shadowOffset = CGSize(width: 0, height: 3)
            self.viewMain.layer.shadowOpacity = 0.8
            self.viewMain.layer.shadowRadius = 5
            self.viewMain.layer.masksToBounds = false
            self.viewMain.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 5, y: 5, width: self.viewMain.bounds.width - 3, height: self.viewMain.bounds.height - 3), cornerRadius: self.viewMain.layer.shadowRadius).cgPath
            self.viewMain.layer.shouldRasterize = true
        }
    }
    
    @IBAction func eventChooseMore(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_CHOOSE_TITLE_NEWS"), object: typeInfo, userInfo: nil)
    }
    
}
