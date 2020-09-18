//
//  StatusOrderHeaderView.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/18/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class StatusOrderHeaderView: UIView {

    @IBOutlet weak var lblStatus: UILabel!
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#EC8225").cgColor, Tools.hexStringToUIColor(hex: "#F8AB25").cgColor]
        gradientLayer.startPoint = .zero
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        return gradientLayer
    }()
    
    class func instanceFromNib() -> StatusOrderHeaderView{
        return UINib(nibName: "StatusOrderHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! StatusOrderHeaderView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.insertSublayer(gradientLayer, at: 0)
        lblStatus.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
}
