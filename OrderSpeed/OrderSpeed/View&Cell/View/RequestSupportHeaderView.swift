//
//  RequestSupportHeaderView.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/19/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class RequestSupportHeaderView: UIView {

    @IBOutlet weak var tfTitle: BottomLineTextField!
    @IBOutlet weak var tfContent: CustomTextViewPlaceHolder!
    @IBOutlet weak var btnSend: UIButton!
    
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#DC7942").cgColor, Tools.hexStringToUIColor(hex: "#F8AB25").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        return gradientLayer
    }()
    
    class func instanceFromNib() -> RequestSupportHeaderView {
        return UINib(nibName: "RequestSupportHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! RequestSupportHeaderView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnSend.layer.insertSublayer(gradientLayer, below: btnSend.titleLabel?.layer)
        tfTitle.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = btnSend.bounds
    }
    
    func checkDataInpunt() -> Bool {
        var flag = true
        if (tfTitle.text?.isEmpty ?? false) {
            tfTitle.isChecked = false
            flag = false
        }
        if tfContent.text.isEmpty {
            tfContent.isChecked = false
            flag = false
        }
        return flag
    }
}

extension RequestSupportHeaderView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tfTitle.isChecked = true
    }
}
