//
//  LoginViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/3/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class LoginViewController: MainViewController {

    @IBOutlet weak var topLabelTitle: NSLayoutConstraint!
    @IBOutlet weak var topBtnForgot: NSLayoutConstraint!
    @IBOutlet weak var topLogo: NSLayoutConstraint!
    @IBOutlet weak var sizeLogo: NSLayoutConstraint!
    @IBOutlet weak var widthStack: NSLayoutConstraint!
    @IBOutlet weak var topStack: NSLayoutConstraint!
    @IBOutlet weak var topLoginOther: NSLayoutConstraint!
    
    @IBOutlet weak var stackInput: UIStackView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#F5A125").cgColor, Tools.hexStringToUIColor(hex: "#EC8325").cgColor]
        return gradientLayer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.insertSublayer(gradientLayer, below: self.stackInput.layer)

        let screenMain = UIScreen.main.bounds
        if screenMain.width <= 320.0 && screenMain.height <= 568 {
            topLabelTitle.constant = 24
            sizeLogo.constant = 80
            topLogo.constant = 16
            widthStack.constant = 40
            topStack.constant = 16
            topBtnForgot.constant = 8
            topLoginOther.constant = 22
        }
        
        #if DEBUG
        tfEmail.text = "nguyenvantam110@gmail.com"
        tfPassword.text = "113456"
        #endif
        
        addLoginFacebook()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(eventRegisterSuccess(_:)), name: NSNotification.Name("REGISTER_SUCCESS"), object: nil)
    }
    
    @objc func eventRegisterSuccess(_ notification:Notification) {
        if let arrInfo = notification.object as? [String], arrInfo.count == 2 {
            tfEmail.text = arrInfo.first
            tfPassword.text = arrInfo.last
        }
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = self.view.bounds
        borderInputView()
    }
    
    func borderInputView() {
        for inputView in stackInput.arrangedSubviews {
            if let tf = inputView as? UITextField {
                tf.delegate = self
                tf.layer.borderColor = Tools.hexStringToUIColor(hex: "#BDBDBD").cgColor
                tf.layer.borderWidth = 1.0
                
                let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
                tf.leftView = leftView
                tf.leftViewMode = .always
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
        }
    }
    
    @objc func eventChooseShowPassword(_ tap: UITapGestureRecognizer) {
        tfPassword.isSecureTextEntry = !tfPassword.isSecureTextEntry
    }
    
    func addLoginFacebook() {
//        let btnLogin = FBLoginButton(type: .custom)
//        btnLogin.permissions = ["public_profile", "email"]
//        btnLogin.delegate = self
//        viewBtnFacebook.addSubview(btnLogin)
//        btnLogin.center = viewBtnFacebook.center
//        btnLogin.frame = CGRect(x: 0, y: 0, width: viewBtnFacebook.frame.width, height: viewBtnFacebook.frame.height)
    }
    
    
    func checkInputData() -> Bool {
        var flag = true
        if let arrInputView = stackInput.arrangedSubviews as? [UITextField] {
            for inputView in arrInputView {
                if inputView.text?.isEmpty ?? false {
                    flag = false
                    inputView.shakeAnimationTextField()
                }
            }
        }
//        if flag {
//            flag = Tools.isValidEmail(email: tfEmail.text!)
//            if !flag {
//                tfEmail.shakeAnimationTextField()
//            }
//        }
        return flag
    }
    
    @IBAction func eventChooseLogin(_ sender: Any) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        if checkInputData() {
            loginWithFireAuth(tfEmail.text!, password: tfPassword.text!)
        } else {
            print("\(TAG) - \(#function) - \(#line) - input == nil")
        }
    }
    
    @IBAction func eventChooseRegister(_ sender: Any) {
        let vc = RegisterViewController(nibName: "RegisterViewController", bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func eventChooseLoginWithGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func eventChooseLoginWithFacebook(_ sender: Any) {
        DispatchQueue.main.async {
            self.progessHUD.showInViewWithMessage(self.view, message: "Đăng nhập...")
        }
        let login = LoginManager()
        login.logIn(permissions: ["public_profile", "email"], from: self) { [weak self](result, error) in
            if let result = result {
                if result.isCancelled {
                    self?.hideProgressHUD()
                    print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - cancelled")
                } else {
                    let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                    Auth.auth().signIn(with: credential) { [weak self](authResult, error) in
                        if let error = error {
                            debugPrint("\(self!.TAG) - \(#function) - line : \(#line) - error : \(error.localizedDescription)")
                            self?.hideProgressHUD()
                            self?.showErrorAlertView(error.localizedDescription)
                            return
                        }
                        else {
                            self?.loginWithCredential(authResult)
                        }
                    }
                }
            } else {
                self?.hideProgressHUD()
                self?.showErrorAlertView(error.debugDescription)
            }
        }
    }
    
    func loginWithFireAuth(_ email:String, password:String) {
        DispatchQueue.main.async {
            self.progessHUD.showInViewWithMessage(self.view, message: "Đăng nhập...")
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self](result, error) in
            guard let strongSelf = self else {
                self?.hideProgressHUD()
                return
            }
            self?.hideProgressHUD()
            guard let _result = result, error == nil else {
                print("\(strongSelf.TAG) - \(#function) - \(#line) - \(error.debugDescription)")
                DispatchQueue.main.async {
                    strongSelf.showErrorAlertView(error?.localizedDescription ?? "Có lỗi xảy ra, vui lòng thử lại sau.")
                }
                return
            }
            strongSelf.loginWithCredential(_result)
        }
    }
    
    func loginWithCredential(_ authResult:AuthDataResult?) {
        debugPrint("\(TAG) - \(#function) - line : \(#line) - authResult : \(String(describing: authResult?.user.uid)) - \(String(describing: authResult?.user.email)) - \(String(describing: authResult?.user.photoURL))")
        
        guard let uid = authResult?.user.uid else {
            self.hideProgressHUD()
            return
        }
        self.dbFireStore.collection("User").whereField("uid", isEqualTo: uid).limit(to: 1).getDocuments { [weak self](querySnapshot, err) in
            guard let snapshot = querySnapshot else {
                debugPrint("\(self!.TAG) - \(#function) - line : \(#line) - err : \(err.debugDescription)")
                self?.hideProgressHUD()
                return
            }

            guard let document = snapshot.documents.first else {
                debugPrint("\(self!.TAG) - \(#function) - line : \(#line) - không tìm thấy thư mục user")
                self?.createFolderUser(authResult)
                return
            }

            DispatchQueue.main.async {
                self?.hideProgressHUD()
            }
            let dicUser = document.data()
            self?.saveUserAfterLogin(dicUser)
        }
    }
    
    func saveUserAfterLogin(_ dict:[String:Any]) {
        var sAvartar = dict["avatar"] as? String ?? ""
        if sAvartar.hasPrefix("https://graph.facebook.com") {
            sAvartar = "\(sAvartar)?type=large"
        }
        
        debugPrint("\(String(describing: self.TAG)) - \(#function) - line : \(#line) - sAvartar : \(sAvartar)")
        let user = UserBeer(id: dict["uid"] as? String ?? "", roleid: "", email: dict["email"] as? String ?? "", fullname: dict["user_name"] as? String ?? "", avatar: sAvartar, phoneNumber: dict["phone_number"] as? String ?? "", address: dict["address"] as? String ?? "", tokenAPN: dict["apn_key"] as? String ?? "")
        user.showInfo()
        Tools.saveUserInfo(user)
        self.appDelegate.user = user
        NotificationCenter.default.post(name: NSNotification.Name("LOGIN_FINISH"), object: nil)
//        DispatchQueue.main.async {
//            self.dismiss()
//        }
    }
    
    func createFolderUser(_ authResult:AuthDataResult?) {
        guard let auth = authResult else { return }
        let userName = auth.user.displayName ?? ""
        var queryable = [String]()
        if userName.contains(" ") {
            let arrTemp = userName.components(separatedBy: " ")
            for item in arrTemp {
                queryable.append(item.lowercased())
            }
        } else {
            queryable.append(userName.lowercased())
        }
        let registerDic:[String : Any] = ["uid": auth.user.uid, "email":authResult?.user.email ?? "","user_name":userName, "avatar":auth.user.photoURL?.absoluteString ?? "", "queryable":queryable, "first_name":"", "last_name":"", "job_title":"", "department":"", "organization":"", "based_in":"", "address":"", "isEnable":true]
        let dbBatch = self.dbFireStore.batch()
        
        debugPrint("\(TAG) - \(#function) - line : \(#line) - _uid : \(auth.user.uid)")
        let refUser = self.dbFireStore.collection("User").document(auth.user.uid)
        dbBatch.setData(registerDic, forDocument: refUser)
        
        dbBatch.commit { [weak self](error) in
            self?.hideProgressHUD()
            if let error = error {
                debugPrint("\(String(describing: self?.TAG)) - \(#function) - line : \(#line) - error : \(error.localizedDescription)")
                return
            }
            self?.saveUserAfterLogin(registerDic)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfEmail {
            tfPassword.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = Tools.hexStringToUIColor(hex: "#BDBDBD").cgColor
    }
}

extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            debugPrint("\(self.TAG) - \(#function) - line : \(#line) - error : \(error.localizedDescription)")
            self.showErrorAlertView(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else {
            debugPrint("\(self.TAG) - \(#function) - line : \(#line) - co loi khi authentication")
            self.showErrorAlertView("Lỗi khi Authentication đăng nhập.")
            return
        }
        
        DispatchQueue.main.async {
            self.progessHUD.showInViewWithMessage(self.view, message: "Đăng nhập...")
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
        accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { [weak self](authResult, error) in
            if let error = error {
                debugPrint("\(self!.TAG) - \(#function) - line : \(#line) - error : \(error.localizedDescription)")
                self?.hideProgressHUD()
                self?.showErrorAlertView(error.localizedDescription)
                return
            }
            else {
                self?.loginWithCredential(authResult)
            }
        }
    }
    
    
}
