//
//  ReceiverInfoTableCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/8/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

protocol ReceiverInfoCellDelegate {
    func inputInfo(_ info: (String, String, String, String, String, String))
}

class ReceiverInfoTableCell: UITableViewCell {

    @IBOutlet weak var tfName: BottomLineTextField!
    @IBOutlet weak var tfPhone: BottomLineTextField!
    @IBOutlet weak var tfTinhThanh: BottomLineTextField!
    @IBOutlet weak var tfQuanHuyen: BottomLineTextField!
    @IBOutlet weak var tfAddress: BottomLineTextField!
    @IBOutlet weak var tfNote: CustomTextViewPlaceHolder!
    @IBOutlet weak var controlCity: UIControl!
    @IBOutlet weak var controlDistrict: UIControl!
    var delegate: ReceiverInfoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tfName.delegate = self
        tfPhone.delegate = self
        tfAddress.delegate = self
        tfNote.customDelegate = self
    }
    
    func getInfo() -> (String, String, String, String, String, String) {
        let receiverName = tfName.text ?? ""
        let receiverPhone = tfPhone.text ?? ""
        var cityName = tfTinhThanh.text ?? ""
        if cityName == "Chọn tỉnh/thành phố" {
            cityName = ""
        }
        var districtName = tfQuanHuyen.text ?? ""
        if districtName == "Chọn quận/huyện" {
            districtName = ""
        }
        let address = tfAddress.text ?? ""
        let note = tfNote.text ?? ""
        return (receiverName, receiverPhone, cityName, districtName, address, note)
    }
    
    func showInfo(_ name: String, phone: String, cityName: String, districtName: String, address: String, note: String) {
        tfName.text = name
        tfPhone.text = phone
        tfTinhThanh.text = cityName.isEmpty ? "Chọn tỉnh/thành phố" : cityName
        tfQuanHuyen.text = districtName.isEmpty ? "Chọn quận/huyện" : districtName
        tfAddress.text = address
        tfNote.text = note
        tfNote.placeholder = note.isEmpty ? "Ghi chú" : ""
    }
}

extension ReceiverInfoTableCell: CustomTextViewDelegate {
    func customTextViewEndEditting(_ textView: UITextView) {
        delegate?.inputInfo(getInfo())
    }
}

extension ReceiverInfoTableCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.inputInfo(getInfo())
    }
}
