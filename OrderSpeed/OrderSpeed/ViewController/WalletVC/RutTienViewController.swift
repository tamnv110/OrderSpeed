//
//  RutTienViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 23/12/2020.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RutTienViewController: MainViewController {

    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblBank: UILabel!
    @IBOutlet weak var tfBranch: BottomLineTextField!
    @IBOutlet weak var tfAccountName: BottomLineTextField!
    @IBOutlet weak var tfBankNumber: BottomLineTextField!
    @IBOutlet weak var lblMoney: BottomLineTextField!
    @IBOutlet weak var tfCode: BottomLineTextField!
    @IBOutlet weak var lineBank: UIView!
    @IBOutlet weak var btnGetCode: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    
    var timeCountdown = 120
    var timerOTP: Timer?
    var bankName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = self.appDelegate.user {
            lblAmount.text = Tools.convertCurrencyFromString(input: "\(Tools.convertCurrencyFromString(input: Tools.convertCurrencyFromString(input: String(format: "%.0f", user.totalMoney))))") + " đ"
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_CHOOSE_BANK"), object: nil, queue: .main) { (notification) in
            if let bankName = notification.object as? String {
                self.lblBank.textColor = .black
                self.lblBank.text = bankName
                self.bankName = bankName
            }
        }
        lblTime.isHidden = true
        tfCode.delegate = self
        tfBranch.delegate = self
        tfAccountName.delegate = self
        tfBankNumber.delegate = self
        lblMoney.delegate = self
        lblMoney.addTarget(self, action: #selector(eventValueChanged(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Rút tiền"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    @objc func eventValueChanged(_ tf: BottomLineTextField) {
        if let content = tf.text {
            tf.text = Tools.convertCurrencyFromString(input: content)
        }
    }

    @IBAction func eventChooseBank(_ sender: Any) {
        lineBank.backgroundColor = Tools.hexStringToUIColor(hex: "#D2D2D2")
        let vc = ListBanksViewController(nibName: "ListBanksViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func eventChooseGetCode(_ sender: Any) {
        self.view.endEditing(true)
        if checkInputData(1) {
            if timeCountdown != 120 {
                return
            }
            guard let user = self.appDelegate.user else { return }
            timerOTP = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerOTP), userInfo: nil, repeats: true)
            lblTime.isHidden = false
            self.showProgressHUD("Lấy OTP...")
            let paramter = ["email": user.email, "uid": user.userID]
            Alamofire.request("http://orderspeed.vn/api/user/otp", method: .post, parameters: paramter, encoding: JSONEncoding.default).responseData { [weak self](response) in
                DispatchQueue.main.async {
                    self?.hideProgressHUD()
                }
                switch response.result {
                case .success(let data):
                    do {
                        let json = try JSON(data: data)
                        if let msg = json["message"].string {
                            self?.showAlertView(msg, completion: {

                            })
                        }
                    } catch {
                        print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc func updateTimerOTP() {
        timeCountdown -= 1
        
        let minute = timeCountdown / 60
        let second = timeCountdown % 60
        DispatchQueue.main.async {
            self.lblTime.text = "\(minute):\(second)"
        }
        if timeCountdown <= 0 {
            timeCountdown = 120
            timerOTP?.invalidate()
        }
    }
    
    @IBAction func eventChooseReset(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    func checkInputData(_ type: Int) -> Bool {
        let totalMoney: Double = self.appDelegate.user?.totalMoney ?? 0
        if totalMoney <= 0 {
            self.showAlertView("Số dư trong Ví không đủ để thực hiện giao dịch.") {

            }
            return false
        }
        var flag = true
        if bankName.isEmpty {
            flag = false
            lineBank.backgroundColor = .red
        }
        var arrInputViews = [tfAccountName!, tfBankNumber!, lblMoney!, tfCode!]
        if type == 1 {
            arrInputViews = [tfAccountName!, tfBankNumber!, lblMoney!]
        }
        for input in arrInputViews {
            let content = input.text ?? ""
            if content.isEmpty {
                flag = false
                input.isChecked = false
            }
        }
        if flag {
            let sMoney = (lblMoney.text ?? "")
            let money = Double(sMoney.replacingOccurrences(of: ",", with: "")) ?? 0
            if money == 0 || money > totalMoney {
                self.showAlertView("Số tiền giao dịch phải lớn hơn 0 đ và nhỏ hơn hoặc bằng số dư trong Ví.") {
                    
                }
                flag = false
            }
        }
        return flag
    }
    
    @IBAction func eventChooseContinue(_ sender: Any) {
        self.view.endEditing(true)
        if checkInputData(0) {
            self.showProgressHUD("Đang xử lý...")
            let sOTP = tfCode.text ?? ""
            connectCheckOTP(sOTP) { (result) in
                if result {
                    self.connectCreateTransaction()
                } else {
                    print("\(self.TAG) - \(#function) - \(#line) - nhap sai OTP")
                    DispatchQueue.main.async {
                        self.hideProgressHUD()
                    }
                }
            }
        }
    }
    
    func connectCreateTransaction() {
        guard let user = appDelegate.user else {
            DispatchQueue.main.async {
                self.hideProgressHUD()
            }
            return
        }
        let sMoney = (lblMoney.text ?? "")
        let money = Double(sMoney.replacingOccurrences(of: ",", with: "")) ?? 0
        let userCode = user.code
        let code = Tools.randomString(length: 10)
        let createAt = Tools.convertDateToString(Date(), dateFormat: "yyyy-MM-dd HH:mm:ss")
        let balance = user.totalMoney
        let status = 0
        let type = 1
        var content = "Rút tiền: rút \(sMoney.replacingOccurrences(of: ",", with: ".")) về tài khoản \(tfBankNumber.text ?? "") - \(tfAccountName.text ?? ""), ngân hàng \(bankName)"
        let sBranch = tfBranch.text ?? ""
        if !sBranch.isEmpty {
            content.append(", chi nhánh \(sBranch)")
        }
        let dict: [String: Any] = ["balance": balance, "change": false, "code": code, "content": content, "money": money, "status": status, "type": type, "created_at": createAt, "updated_at": createAt, "user_code": userCode, "user_id": user.userID]
        print("\(TAG) - \(#function) - \(#line) - dict : \(dict)")
        let batch = self.dbFireStore.batch()
        let refColTransaction = self.dbFireStore.collection(OrderFolderName.transaction.rawValue)
        let refDocTrans = refColTransaction.document()
        batch.setData(dict, forDocument: refDocTrans)
        
        let refColUser = self.dbFireStore.collection(OrderFolderName.rootUser.rawValue)
        let refDocUser = refColUser.document(user.userID)
        let remainBalance = user.totalMoney - money
        batch.updateData(["total_money": remainBalance], forDocument: refDocUser)
        batch.commit { [weak self](error) in
            DispatchQueue.main.async {
                self?.hideProgressHUD()
            }
            if let error = error {
                print("\(self?.TAG) - \(#function) - \(#line) - error : \(error.localizedDescription)")
            } else {
                self?.showAlertView("Tạo giao dịch rút tiền thành công. Chúng tôi sẽ kiểm tra và chuyển tiền cho quý khách trong 24h.", completion: {
                    user.totalMoney = remainBalance
                    Tools.saveUserInfo(user)
                    self?.appDelegate.user = user
                    NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_WITH_DRAW"), object: nil)
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
}

extension RutTienViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let tf = textField as? BottomLineTextField, !tf.isChecked {
            tf.isChecked = true
        }
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
