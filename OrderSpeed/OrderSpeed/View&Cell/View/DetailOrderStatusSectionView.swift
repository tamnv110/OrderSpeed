//
//  DetailOrderStatusSectionView.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/18/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class DetailOrderStatusSectionView: UIView {

    @IBOutlet weak var lblOrderCode: UILabel!
    @IBOutlet weak var lblSubTotal: UILabel!
    @IBOutlet weak var lblFee: UILabel!
    @IBOutlet weak var lblTotalMoney: UILabel!
    @IBOutlet weak var lblDepositMoney: UILabel!
    @IBOutlet weak var lblRestMoney: UILabel!
    
    class func instanceFromNib() -> DetailOrderStatusSectionView {
        return UINib(nibName: "DetailOrderStatusSectionView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! DetailOrderStatusSectionView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func showInfo(_ item: OrderProductDataModel) {
        lblOrderCode.text = item.code
        lblSubTotal.text = Tools.convertCurrencyFromString(input: String(format: "%.0f", item.subTotalMoney)) + " VND"
        lblFee.text = Tools.convertCurrencyFromString(input: "\(String(format: "%.0f", item.serviceCost))") + " VND"
        let totalMoney = item.subTotalMoney + item.serviceCost
        lblTotalMoney.text = Tools.convertCurrencyFromString(input: String(format: "%.0f", totalMoney)) + " VND"
        lblDepositMoney.text = Tools.convertCurrencyFromString(input: String(format: "%.0f", item.depositMoney)) + " VND"
        let moneyRest = totalMoney - item.depositMoney
        lblRestMoney.text = Tools.convertCurrencyFromString(input: String(format: "%.0f", moneyRest)) + " VND"
    }
}
