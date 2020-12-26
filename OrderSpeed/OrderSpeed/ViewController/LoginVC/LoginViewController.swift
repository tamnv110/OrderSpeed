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
import CryptoKit
import AuthenticationServices

class LoginViewController: MainViewController {

    @IBOutlet weak var topLabelTitle: NSLayoutConstraint!
    @IBOutlet weak var topBtnForgot: NSLayoutConstraint!
//    @IBOutlet weak var topLogo: NSLayoutConstraint!
    @IBOutlet weak var sizeLogo: NSLayoutConstraint!
    @IBOutlet weak var widthStack: NSLayoutConstraint!
    @IBOutlet weak var topStack: NSLayoutConstraint!
    @IBOutlet weak var viewSiginApple: UIView!
    
    
    @IBOutlet weak var stackInput: UIStackView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    var typeLogin = 0
    
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#F5A125").cgColor, Tools.hexStringToUIColor(hex: "#EC8325").cgColor]
        return gradientLayer
    }()
    var apnsKey = ""
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.insertSublayer(gradientLayer, below: self.stackInput.layer)

//        let screenMain = UIScreen.main.bounds
//        if screenMain.width <= 320.0 && screenMain.height <= 568 {
//            topLabelTitle.constant = 24
//            sizeLogo.constant = 60
//            widthStack.constant = 40
//            topStack.constant = 16
//            topBtnForgot.constant = 8
//        }
//        #if DEBUG
//        tfEmail.text = "nguyenvantam110@gmail.com"
//        tfPassword.text = "113456"
//        #endif
        tfEmail.delegate = self
        tfPassword.delegate = self
        setupSigninApple()
        addLoginFacebook()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(eventRegisterSuccess(_:)), name: NSNotification.Name("REGISTER_SUCCESS"), object: nil)
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("\(self.TAG) - \(#function) - \(#line) - Error fetching remote instance ID: \(error)")
            } else if let result = result {
                self.apnsKey = result.token
                print("\(self.TAG) - \(#function) - \(#line) - Remote instance ID token: \(result.token)")
            }
        }
    }
    
    //MARK: - Signin Apple
    func setupSigninApple() {
        viewSiginApple.backgroundColor = UIColor.clear
        if #available(iOS 13.0, *) {
            let authorizationButton = ASAuthorizationAppleIDButton()
            authorizationButton.translatesAutoresizingMaskIntoConstraints = false
            viewSiginApple.addSubview(authorizationButton)
            authorizationButton.leadingAnchor.constraint(equalTo: viewSiginApple.leadingAnchor).isActive = true
            authorizationButton.trailingAnchor.constraint(equalTo: viewSiginApple.trailingAnchor).isActive = true
            authorizationButton.topAnchor.constraint(equalTo: viewSiginApple.topAnchor).isActive = true
            authorizationButton.bottomAnchor.constraint(equalTo: viewSiginApple.bottomAnchor).isActive = true
//            authorizationButton.anchor(top: viewSiginApple.topAnchor, leading: viewSiginApple.leadingAnchor, bottom: viewSiginApple.bottomAnchor, trailing: viewSiginApple.trailingAnchor)
            authorizationButton.addTarget(self, action: #selector(eventChooseSigninWithApple(_:)), for: .touchUpInside)
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    @available(iOS 13, *)
    @objc func eventChooseSigninWithApple(_ sender: Any) {
        typeLogin = 3
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
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
        return flag
    }
    
    @IBAction func eventChooseForgotPassword(_ sender: Any) {
        let alertForgot = UIAlertController(title: "Quên mật khẩu", message: "Nhập địa chỉ email của bạn, chúng tôi sẽ gửi một email chứa mật khẩu mới.", preferredStyle: .alert)
        alertForgot.addTextField { (tf) in
            tf.keyboardType = .emailAddress
            tf.placeholder = "Nhập địa chỉ email"
        }
        let cancel = UIAlertAction(title: "Đóng", style: .cancel, handler: nil)
        let continute = UIAlertAction(title: "Gửi", style: .default) { (action) in
            if let tf = alertForgot.textFields?.first, let email = tf.text, Tools.isValidEmail(email: email) {
                self.showProgressHUD("Quên mật khẩu...")
                Auth.auth().sendPasswordReset(withEmail: email) { [weak self](error) in
                    self?.hideProgressHUD()
                    if let _ = error {
                        self?.showErrorAlertView("Có lỗi xảy ra, vui lòng thử lại sau.") {
                        }
                    } else {
                        self?.showAlertView("Vui lòng kiểm tra email của bạn để lấy lại mật khẩu.") {
                            
                        }
                    }
                }
            }
        }
        alertForgot.addAction(cancel)
        alertForgot.addAction(continute)
        self.present(alertForgot, animated: true, completion: nil)
    }
    
    @IBAction func eventChooseLogin(_ sender: Any) {
        typeLogin = 0
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
        typeLogin = 1
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func eventChooseLoginWithFacebook(_ sender: Any) {
        typeLogin = 2
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
                            self?.showErrorAlertView(error.localizedDescription){}
                            return
                        }
                        else {
                            self?.loginWithCredential(authResult)
                        }
                    }
                }
            } else {
                self?.hideProgressHUD()
                self?.showErrorAlertView(error.debugDescription){}
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
                    strongSelf.showErrorAlertView(error?.localizedDescription ?? "Có lỗi xảy ra, vui lòng thử lại sau."){}
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
        self.dbFireStore.collection(OrderFolderName.rootUser.rawValue).whereField("uid", isEqualTo: uid).limit(to: 1).getDocuments { [weak self](querySnapshot, err) in
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
        let registerDic:[String : Any] = ["uid": auth.user.uid, "email": authResult?.user.email ?? "","user_name": userName, "avatar": auth.user.photoURL?.absoluteString ?? "", "queryable": queryable, "address": "", "city_name": "", "district_name": "","isEnable":true, "phone": "", "apn_key": self.apnsKey, "receiver_name": "", "typeAcc": 2, "type": "customer"]
        let dbBatch = self.dbFireStore.batch()
        
        debugPrint("\(TAG) - \(#function) - line : \(#line) - _uid : \(auth.user.uid)")
        debugPrint("\(TAG) - \(#function) - line : \(#line) - registerDic : \(registerDic)")
        
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
    
    func saveUserAfterLogin(_ dict:[String:Any]) {
        var sAvartar = dict["avatar"] as? String ?? ""
        if sAvartar.hasPrefix("https://graph.facebook.com") {
            sAvartar = "\(sAvartar)?type=large"
        }
        
        debugPrint("\(String(describing: self.TAG)) - \(#function) - line : \(#line) - sAvartar : \(sAvartar)")
        let user = UserBeer(id: dict["uid"] as? String ?? "", email: dict["email"] as? String ?? "", fullname: dict["user_name"] as? String ?? "", avatar: sAvartar, phoneNumber: dict["phone"] as? String ?? "", receiverPhone: dict["receiver_phone"] as? String ?? "", receiverName: dict["receiver_name"] as? String ?? "", address: dict["address"] as? String ?? "", cityName: dict["city_name"] as? String ?? "", districtName: dict["district_name"] as? String ?? "", tokenAPN: dict["apn_key"] as? String ?? "", typeAcc: dict["typeAcc"] as? Int ?? 2, totalMoney: dict["total_money"] as? Double ?? 0.0)
        user.showInfo()
        if !self.apnsKey.isEmpty {
            print("\(TAG) - \(#function) - \(#line) =====> update tokenAPN")
            user.tokenAPN = self.apnsKey
            self.dbFireStore.collection(OrderFolderName.rootUser.rawValue).document(user.userID).updateData(["apn_key": self.apnsKey])
        }
        Tools.saveUserInfo(user)
        Tools.saveObjectToDefault(typeLogin, key: Tools.KEY_LOGIN_TYPE)
        self.appDelegate.user = user
        
        NotificationCenter.default.post(name: NSNotification.Name("LOGIN_FINISH"), object: nil)
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
            self.showErrorAlertView(error.localizedDescription){}
            return
        }
        
        guard let authentication = user.authentication else {
            debugPrint("\(self.TAG) - \(#function) - line : \(#line) - co loi khi authentication")
            self.showErrorAlertView("Lỗi khi Authentication đăng nhập."){}
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
                self?.showErrorAlertView(error.localizedDescription){}
                return
            }
            else {
                self?.loginWithCredential(authResult)
            }
        }
    }
    
    
}

extension LoginViewController : ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { [unowned self](authResult, error) in
                if let err = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print("\(self.TAG) - \(#function) - \(#line) - err : \(err.localizedDescription)")
                    self.hideProgressHUD()
                    self.showAlertView("Have a problem when login. Please try again later.", completion: {})
                    return
                }
                else {
                    self.loginWithCredential(authResult)
                }
            }
        }
    }
}

extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
}
