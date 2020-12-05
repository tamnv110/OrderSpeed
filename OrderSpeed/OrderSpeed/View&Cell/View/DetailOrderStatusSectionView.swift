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
    @IBOutlet weak var lblCocDuKien: UILabel!
    @IBOutlet weak var lblWeight: UILabel!
    
    class func instanceFromNib() -> DetailOrderStatusSectionView {
        return UINib(nibName: "DetailOrderStatusSectionView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! DetailOrderStatusSectionView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func showInfo(_ item: OrderProductDataModel) {
        lblOrderCode.text = item.code
        lblSubTotal.text = Tools.convertCurrencyFromString(input: String(format: "%.0f", item.subTotalMoney)) + " đ"
        lblFee.text = Tools.convertCurrencyFromString(input: "\(String(format: "%.0f", item.serviceCost))") + " đ"
        let totalMoney = item.subTotalMoney + item.serviceCost
        lblTotalMoney.text = Tools.convertCurrencyFromString(input: String(format: "%.0f", totalMoney)) + " đ"
        lblDepositMoney.text = Tools.convertCurrencyFromString(input: String(format: "%.0f", item.depositMoney)) + " đ"
        let moneyRest = totalMoney - item.depositMoney
        lblRestMoney.text = Tools.convertCurrencyFromString(input: String(format: "%.0f", moneyRest)) + " đ"
        
        let tienCocDuKien = ceil(totalMoney * 0.8)
        lblCocDuKien.text = Tools.convertCurrencyFromString(input: String(format: "%.0f", tienCocDuKien)) + " đ"
        
        lblWeight.text = item.weight == 0.0 ? "Đang cập nhật" : "\(item.weight) kg"
    }
}
