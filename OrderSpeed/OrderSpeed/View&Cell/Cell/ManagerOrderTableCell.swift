//
//  ManagerOrderTableCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/16/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class ManagerOrderTableCell: UITableViewCell {

    @IBOutlet weak var lblOrderCode: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblReceiveName: UILabel!
    @IBOutlet weak var lblReceiveAddress: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblAmountTitle: UILabel!
    @IBOutlet weak var btnSupport: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnSupport.layer.cornerRadius = btnSupport.frame.height / 2
        btnEdit.layer.cornerRadius = btnEdit.frame.height / 2
    }
    
    func showInfo(_ item: OrderProductDataModel) {
        lblOrderCode.text = item.code
        lblStatus.text = item.status.isEmpty ? "Chờ báo giá" : item.status
        
        if !item.receiverName.isEmpty {
            lblReceiveName.text = item.receiverName + " - " + item.receiverPhone
            lblReceiveAddress.text = "\(item.receiverAddress), \(item.districtName), \(item.cityName)"
        } else {
            lblReceiveName.text = item.warehouseName
            lblReceiveAddress.text = item.warehouseAddress
        }
        let money = ceil(item.subTotalMoney + item.serviceCost)
        if item.depositMoney == 0 {
            lblAmount.text = Tools.convertCurrencyFromString(input: String(format: "%.0f", money)) + " VND"
            lblAmountTitle.text = "Tổng tiền tạm tính:"
        } else {
            let moneyRest = ceil(money - item.depositMoney)
            lblAmount.text = Tools.convertCurrencyFromString(input: String(format: "%.0f", moneyRest)) + " VND"
            lblAmountTitle.text = "Thanh toán còn thiếu:"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: item.createAt) {
            formatter.dateFormat = "HH:mm dd/MM/yyyy"
            lblDate.text = formatter.string(from: date)
        } else {
            lblDate.text = nil
        }
        
        btnEdit.setTitle(item.depositMoney > 0 ? "Hủy" : "Chỉnh sửa", for: .normal)
        
        if item.status.lowercased() == "đã huỷ" || item.status.lowercased() == "đã hủy" {
            btnEdit.setTitle("Đã hủy", for: .normal)
        }
    }
}
