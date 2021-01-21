//
//  PaymentOrderHeaderView.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 30/12/2020.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class PaymentOrderHeaderView: UIView {

    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfMoney: BottomLineTextField!
    @IBOutlet weak var tfCode: BottomLineTextField!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnGetCode: UIButton!
    @IBOutlet weak var btnPayment: UIButton!
    
    var timer: Timer?
    var nCountDown = 120
    
    class func instanceFromNib() -> PaymentOrderHeaderView {
        return UINib(nibName: "PaymentOrderHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! PaymentOrderHeaderView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        lblTime.isHidden = true
        tfCode.delegate = self
        tfMoney.delegate = self
        tfMoney.addTarget(self, action: #selector(eventValueChanged(_:)), for: .editingChanged)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    @objc func eventValueChanged(_ tf: BottomLineTextField) {
        if let content = tf.text {
            tf.text = Tools.convertCurrencyFromString(input: content)
        }
    }
    
    func startTimer() {
        if nCountDown == 120 {
            lblTime.isHidden = false
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDownTimer(_:)), userInfo: nil, repeats: true)
        }
    }
    
    @objc func countDownTimer(_ timer: Timer) {
        nCountDown -= 1
        let minute = nCountDown / 60
        let second = nCountDown % 60
        DispatchQueue.main.async {
            self.lblTime.text = "\(minute):\(second)"
        }
        if nCountDown <= 0 {
            nCountDown = 120
            timer.invalidate()
        }
    }
    
    func checkInputData() -> Bool {
        var flag = true
        let arrInputView = [tfMoney!, tfCode!]
        for inputView in arrInputView {
            let sContent = inputView.text ?? ""
            if sContent.isEmpty {
                inputView.isChecked = false
                flag = false
            }
        }
        return flag
    }
}

extension PaymentOrderHeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let tf = textField as? BottomLineTextField {
            tf.isChecked = true
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let tf = textField as? BottomLineTextField, tf == tfCode {
            let sCode = tf.text ?? ""
            if sCode.count >= 6 {
                if string.count == 0 {
                    return true
                }
                return false
            }
            return true
        }
        return true
    }
}
