//
//  ChangeAddressViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/21/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class ChangeAddressViewController: MainViewController {

    @IBOutlet weak var scrMain: UIScrollView!
    @IBOutlet weak var tfName: BottomLineTextField!
    @IBOutlet weak var tfPhone: BottomLineTextField!
    @IBOutlet weak var tfCity: BottomLineTextField!
    @IBOutlet weak var tfDistrict: BottomLineTextField!
    @IBOutlet weak var tfAddress: BottomLineTextField!
    @IBOutlet weak var btnContinue: UIButton!
    
    lazy var btnGradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#DC7942").cgColor, Tools.hexStringToUIColor(hex: "#F8AB25").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }()
    
    var cityName = ""
    var districtName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfName.delegate = self
        tfAddress.delegate = self
        
        btnContinue.layer.insertSublayer(btnGradient, below: btnContinue.titleLabel?.layer)
        btnContinue.layer.cornerRadius = btnContinue.bounds.height / 2
        
        tfName.text = self.appDelegate.user?.receiverName
        tfPhone.text = self.appDelegate.user?.phoneNumber
        tfCity.text = self.appDelegate.user?.cityName
        cityName = self.appDelegate.user?.cityName ?? ""
        tfDistrict.text = self.appDelegate.user?.districtName
        districtName = self.appDelegate.user?.districtName ?? ""
        tfAddress.text = self.appDelegate.user?.address
        
        NotificationCenter.default.addObserver(self, selector: #selector(eventShowKeyboard(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventHideKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        btnGradient.frame = btnContinue.bounds
    }
    
    @objc func eventShowKeyboard(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            scrMain.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }
    
    @objc func eventHideKeyboard(_ notification: Notification) {
        scrMain.contentInset = .zero
    }
    
    func checkInput() -> Bool {
        var flag = true
        let arrInputView = [tfName!, tfPhone!, tfAddress!]
        for subview in arrInputView {
            if subview.text?.isEmpty ?? false {
                flag = false
                subview.isChecked = false
            }
        }
        return flag
    }

    @IBAction func eventChooseUpdateAddress(_ sender: Any) {
        guard let user = self.appDelegate.user else { return }
        if checkInput() {
            let batch = self.dbFireStore.batch()
            let userDocRef = self.dbFireStore.collection("User").document(user.userID)
            batch.updateData(["receiver_name": tfName.text ?? ""], forDocument: userDocRef)
            batch.updateData(["receiver_phone": tfPhone.text ?? ""], forDocument: userDocRef)
            batch.updateData(["city_name": cityName], forDocument: userDocRef)
            batch.updateData(["district_name": districtName], forDocument: userDocRef)
            batch.updateData(["address": tfAddress.text ?? ""], forDocument: userDocRef)
            self.showProgressHUD("Cập nhật...")
            batch.commit { [weak self](error) in
                self?.hideProgressHUD()
                if let error = error {
                    print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    self?.showErrorAlertView("Có lỗi xảy ra, vui lòng thử lại sau.", completion: {
                        
                    })
                } else {
                    user.receiverName = self?.tfName.text ?? ""
                    user.receiverPhone = self?.tfPhone.text ?? ""
                    user.cityName = self?.cityName ?? ""
                    user.districtName = self?.districtName ?? ""
                    user.address = self?.tfAddress.text ?? ""
                    Tools.saveUserInfo(user)
                    self?.showAlertView("Cập nhật địa chỉ nhận hàng thành công.", completion: {
                        self?.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
    }
    
    @IBAction func eventChooseCity(_ sender: Any) {
        openChooseCity()
    }
    
    @IBAction func eventChooseDistrict(_ sender: Any) {
        openChooseCity()
    }
    
    func openChooseCity() {
        DispatchQueue.main.async {
            let vc = ChooseCityViewController(nibName: "ChooseCityViewController", bundle: nil)
            vc.delegate = self
            vc.itemSelected = (self.cityName, self.districtName)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ChangeAddressViewController: ChooseCityDelegate {
    func eventChooseCity(_ cityName: String, districtName: String) {
        self.cityName = cityName
        self.districtName = districtName
        tfCity.text = cityName
        tfDistrict.text = districtName
    }
}

extension ChangeAddressViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfName {
            tfPhone.becomeFirstResponder()
        } else if textField == tfAddress {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let tf = textField as? BottomLineTextField {
            tf.isChecked = true
        }
    }
}
