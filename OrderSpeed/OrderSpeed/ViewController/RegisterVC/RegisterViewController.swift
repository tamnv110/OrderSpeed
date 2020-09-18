//
//  RegisterViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/3/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: MainViewController {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var widthLogo: NSLayoutConstraint!
    @IBOutlet weak var topLogo: NSLayoutConstraint!
    @IBOutlet weak var widthStack: NSLayoutConstraint!
    
    lazy var btnGradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#DC7942").cgColor, Tools.hexStringToUIColor(hex: "#F8AB25").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnRegister.tintColor = UIColor.white
        btnRegister.layer.insertSublayer(btnGradient, below: btnRegister.titleLabel?.layer)
        
        borderTextField(tfName)
        borderTextField(tfPhone)
        borderTextField(tfEmail)
        borderTextField(tfPassword)
        
        let screenMain = UIScreen.main.bounds
        if screenMain.width <= 320.0 && screenMain.height <= 568 {
            widthLogo.constant = 80
            topLogo.constant = 16
            widthStack.constant = 40
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(eventTouchToView(_:))))
        
        #if DEBUG
        tfName.text = "Nguyễn Văn Tâm"
        tfPhone.text = "0943910333"
        tfEmail.text = "nguyenvantam110@gmail.com"
        tfPassword.text = "113456"
        #endif
    }
    
    @objc func eventTouchToView(_ gesture: UITapGestureRecognizer) {
        hideKeyboard()
    }
    
    func hideKeyboard() {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    
    func borderTextField(_ tf: UITextField) {
        tf.delegate = self
        tf.layer.borderColor = Tools.hexStringToUIColor(hex: "#BDBDBD").cgColor
        tf.layer.borderWidth = 1
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        tf.leftView = leftView
        tf.leftViewMode = .always
        
        tf.layer.shadowOpacity = 1
        tf.layer.shadowRadius = 3
        tf.layer.shadowOffset = CGSize(width: 0, height: 3)
        tf.layer.shadowColor = UIColor.clear.cgColor
        
        if tf == tfPassword {
            let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 44))
            let imgvView = UIImageView(image: UIImage(named: "icon_eye"))
            imgvView.contentMode = .scaleAspectFill
            imgvView.frame = CGRect(x: 0, y: 13, width: 18, height: 18)
            rightView.addSubview(imgvView)
            tf.rightView = rightView
            tf.rightViewMode = .always
            
            rightView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(eventChooseShowPassword(_:)))
            rightView.addGestureRecognizer(tap)
        }
    }
    
    @objc func eventChooseShowPassword(_ tap: UITapGestureRecognizer) {
        tfPassword.isSecureTextEntry = !tfPassword.isSecureTextEntry
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.btnGradient.frame = self.btnRegister.bounds
        }
    }
    
    func checkInputData() -> Bool {
        var flag = true
        let arrInput = [tfName!, tfPhone!, tfEmail!, tfPassword!]
        for inputView in arrInput {
            let kq = inputView.text?.isEmpty ?? false
            if kq {
                inputView.shakeAnimationTextField()
                flag = false
            }
        }
        if flag {
            let email = tfEmail.text!
            flag = Tools.isValidEmail(email: email)
            if !flag {
                tfEmail.shakeAnimationTextField()
            }
        }
        return flag
    }

    @IBAction func eventChooseRegister(_ sender: Any) {
        hideKeyboard()
        if checkInputData() {
            DispatchQueue.main.async {
                self.progessHUD.showInViewWithMessage(self.view, message: "Đăng ký...")
            }
            let email = tfEmail.text ?? ""
            let password = tfPassword.text ?? ""
            Auth.auth().createUser(withEmail: email, password: password) { [weak self](result, error) in
                guard let strongSelf = self else {
                    self?.hideProgressHUD()
                    return
                }
                guard let _result = result, error == nil else {
                    strongSelf.hideProgressHUD()
                    strongSelf.showErrorAlertView(error!.localizedDescription){}
                    return
                }
                strongSelf.loginWithCredential(_result)
            }
        }
    }
    
    func loginWithCredential(_ authResult:AuthDataResult?) {
        let emailTemp = authResult?.user.email
        let uidTemp = authResult?.user.uid
        debugPrint("\(TAG) - \(#function) - line : \(#line) - email : \(String(describing: emailTemp)) - uidTemp : \(String(describing: uidTemp))")
        if let email = emailTemp, let uid = uidTemp {
            debugPrint("\(TAG) - \(#function) - line : \(#line) - email : \(email)")
            self.dbFireStore.collection("User").whereField("email", isEqualTo: email).limit(to: 1).getDocuments { [weak self](querySnapshot, err) in
                if let err = err {
                    debugPrint("\(String(describing: self?.TAG)) - err : \(err.localizedDescription)")
                    self?.hideProgressHUD()
                    self?.showErrorAlertView(err.localizedDescription){}
                } else {
                    guard let document = querySnapshot?.documents.first else {
                        self?.createDictionaryAndRegister(uid)
                        return
                    }
                    let dicUser = document.data()
                    self?.saveUserAfterLogin(dicUser)
                }
            }
        } else {
            self.hideProgressHUD()
        }
    }
    
    func createDictionaryAndRegister(_ uid:String) {
        var queryable = [String]()
        let userName = tfName.text ?? ""
        if userName.contains(" ") {
            let arrTemp = userName.components(separatedBy: " ")
            for item in arrTemp {
                queryable.append(item.lowercased())
            }
        } else {
            queryable.append(userName.lowercased())
        }
        
        let registerDic:[String : Any] = ["uid":uid, "email":tfEmail.text ?? "","user_name":userName, "queryable":queryable, "first_name":"", "last_name":"", "job_title":"", "department":"", "organization":"", "phone_number":tfPhone.text ?? "", "avatar":"", "address": "", "city_name": "", "district_name": "", "isEnable":true]
        let dbBatch = self.dbFireStore.batch()
        let refUser = self.dbFireStore.collection("User").document(uid)
        dbBatch.setData(registerDic, forDocument: refUser)
        
        dbBatch.commit { [weak self](error) in
            self?.hideProgressHUD()
            if let error = error {
                debugPrint("\(String(describing: self?.TAG)) - \(#function) - line : \(#line) - error : \(error.localizedDescription)")
                self?.showErrorAlertView(error.localizedDescription){}
                return
            }
            self?.saveUserAfterLogin(registerDic)
        }
    }
    
    func saveUserAfterLogin(_ dict:[String:Any]) {
        var sAvartar = dict["avatar"] as? String ?? ""
        if sAvartar.hasPrefix("https://graph.facebook.com") {
            sAvartar = "\(sAvartar)?type=large"
        }
        
        debugPrint("\(String(describing: self.TAG)) - \(#function) - line : \(#line) - sAvartar : \(sAvartar)")
        let user = UserBeer(id: dict["uid"] as? String ?? "", roleid: "", email: dict["email"] as? String ?? "", fullname: dict["user_name"] as? String ?? "", avatar: sAvartar, phoneNumber: dict["phone_number"] as? String ?? "", address: dict["address"] as? String ?? "", cityName: dict["city_name"] as? String ?? "", districtName: dict["district_name"] as? String ?? "", tokenAPN: "")
        user.showInfo()
        Tools.saveUserInfo(user)
        self.appDelegate.user = user
        DispatchQueue.main.async {
            self.showAlertSuccess()
        }
    }
    
    func showAlertSuccess() {
        let alert = UIAlertController(title: "Thông báo", message: "Đăng ký tài khoản thành công!", preferredStyle: .alert)
        let close = UIAlertAction(title: "Tiếp tục", style: .cancel) { (action) in
            NotificationCenter.default.post(name: NSNotification.Name("REGISTER_SUCCESS"), object: [self.tfEmail.text ?? "", self.tfPassword.text ?? ""])
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func eventChooseDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfName {
            tfPhone.becomeFirstResponder()
        } else if textField == tfPhone {
            tfEmail.becomeFirstResponder()
        } else if textField == tfEmail {
            tfPassword.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.layer.borderColor = Tools.hexStringToUIColor(hex: "#BDBDBD").cgColor
            textField.layer.shadowColor = UIColor.gray.cgColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.layer.shadowColor = UIColor.clear.cgColor
        }
    }
}
