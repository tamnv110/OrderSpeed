//
//  RutTienViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 23/12/2020.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class RutTienViewController: MainViewController {

    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblBank: UILabel!
    @IBOutlet weak var tfBranch: BottomLineTextField!
    @IBOutlet weak var tfAccountName: BottomLineTextField!
    @IBOutlet weak var tfBankNumber: BottomLineTextField!
    @IBOutlet weak var lblMoney: BottomLineTextField!
    @IBOutlet weak var tfCode: BottomLineTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = self.appDelegate.user {
            lblAmount.text = Tools.convertCurrencyFromString(input: "\(Tools.convertCurrencyFromString(input: Tools.convertCurrencyFromString(input: String(format: "%.0f", user.totalMoney))))") + " đ"
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_CHOOSE_BANK"), object: nil, queue: .main) { (notification) in
            if let bankName = notification.object as? String {
                self.lblBank.textColor = .black
                self.lblBank.text = bankName
            }
        }

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
        let vc = ListBanksViewController(nibName: "ListBanksViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func eventChooseGetCode(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func eventChooseReset(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func eventChooseContinue(_ sender: Any) {
        self.view.endEditing(true)
    }
}

extension RutTienViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
