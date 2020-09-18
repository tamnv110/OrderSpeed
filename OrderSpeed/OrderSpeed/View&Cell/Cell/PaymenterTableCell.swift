//
//  PaymenterTableCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/9/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

protocol PaymenterTableCellDelegate {
    func inputInfoPayment(_ info: (String, String))
}

class PaymenterTableCell: UITableViewCell {

    @IBOutlet weak var tfName: BottomLineTextField!
    @IBOutlet weak var tfPhone: BottomLineTextField!
    var delegate: PaymenterTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tfName.delegate = self
        tfPhone.delegate = self
    }
    
    func getInfo() -> (String, String) {
        return (tfName.text ?? "", tfPhone.text ?? "")
    }
    
    func showInfo(_ name: String, phone: String) {
        tfName.text = name
        tfPhone.text = phone
    }
}

extension PaymenterTableCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.inputInfoPayment(getInfo())
    }
}
