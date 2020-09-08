//
//  NEWSTableViewCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/4/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class NEWSTableViewCell: UITableViewCell {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    
    lazy var gradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#BD3A52").cgColor, Tools.hexStringToUIColor(hex: "#FED182").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewTitle.layer.insertSublayer(gradient, below: lblType.layer)
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
}
