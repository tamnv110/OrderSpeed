//
//  AccountViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/16/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseUI
import Firebase

class AccountViewController: MainViewController {

    @IBOutlet weak var tbAccount: UITableView!
    lazy var scrollMain: UIScrollView = {
        let scroll = UIScrollView()
//        scroll.backgroundColor = Tools.hexStringToUIColor(hex: "#F5A125")
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .onDrag
        scroll.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scroll)
        scroll.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scroll.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        scroll.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        scroll.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        return scroll
    }()
    
    lazy var vcLogin:LoginViewController = {
        let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
        return vc
    }()
    
    var arrInfoUser: [(String, String, Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ""
        
        let header = AccountHeaderView.instanceFromNib()
        header.btnCamera.addTarget(self, action: #selector(eventChooseChangeAvatar), for: .touchUpInside)
        header.frame = CGRect(x: 0, y: 0, width: tbAccount.frame.width, height: 230)
        tbAccount.tableHeaderView = header
        tbAccount.tableFooterView = UIView(frame: .zero)
        tbAccount.register(UINib(nibName: "ShowTitleTableCell", bundle: nil), forCellReuseIdentifier: "ShowTitleTableCell")
        tbAccount.register(UINib(nibName: "AccountReceiverTableCell", bundle: nil), forCellReuseIdentifier: "AccountReceiverTableCell")
        
        if #available(iOS 11.0, *) {
            tbAccount.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        if let user = self.appDelegate.user {
            showAvatar(user)
            setupInfoShow(user)
        } else {
            tbAccount.isHidden = true
            showLoginController()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("LOGIN_FINISH"), object: nil, queue: .main) { [weak self](notification) in
            self?.vcLogin.willMove(toParent: nil)
            self?.vcLogin.view.removeFromSuperview()
            self?.vcLogin.removeFromParent()
            self?.tbAccount.isHidden = false
            self?.appDelegate.user = Tools.getUserInfo()
            if let user = self?.appDelegate.user {
                self?.showAvatar(user)
                self?.setupInfoShow(user)
            }
            DispatchQueue.main.async {
                self?.tbAccount.reloadData()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("CHANGE_AVATAR"), object: nil, queue: .main) { (notification) in
            guard let imageName = notification.object as? String else {return}
            if let header = self.tbAccount.tableHeaderView as? AccountHeaderView {
                let imageRef = self.storageRef.child("Avatar/\(imageName)")
                header.imgvAvatar.sd_setImage(with: imageRef)
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_CHANGE_ADDRESS"), object: nil, queue: .main) { [weak self](notification) in
            self?.appDelegate.user = Tools.getUserInfo()
            if let user = self?.appDelegate.user {
                self?.setupInfoShow(user)
            }
            DispatchQueue.main.async {
                self?.tbAccount.reloadData()
            }
        }
    }
    
    func showAvatar(_ user: UserBeer) {
        guard let header = tbAccount.tableHeaderView as? AccountHeaderView else { return }
        if user.avatar.isEmpty {
            header.imgvAvatar.image = UIImage(named: "noavatar.png")
        } else {
            if user.avatar.hasPrefix("http") {
                header.imgvAvatar.sd_setImage(with: URL(string: user.avatar), placeholderImage: UIImage(named: "noavatar.png"))
            } else {
                print("\(self.TAG) - \(#function) - \(#line) - user.avatar : \(user.avatar)")
                let avatarRef = self.storageRef.child("Avatar/\(user.avatar)")
                header.imgvAvatar.sd_setImage(with: avatarRef, placeholderImage: UIImage(named: "noavatar.png"))
            }
        }
    }
    
    func setupInfoShow(_ user: UserBeer) {
        let typeAcc = (Tools.getObjectFromDefault(Tools.KEY_LOGIN_TYPE) as? Int) ?? 0
        if typeAcc == 0 {
            arrInfoUser = [("Cập nhật họ tên", user.fullname, 0), ("Cập nhật điện thoại", user.phoneNumber, 1), ("Cập nhật email", user.email, 2), ("Đổi mật khẩu", "Đổi mật khẩu", 110), ("Đăng xuất", "Đăng xuất", 3)]
        } else {
            arrInfoUser = [("Họ tên", user.fullname, 0), ("Số điện thoại", user.phoneNumber, 1), (user.email.isEmpty ? "Cập nhật email" : "Email", user.email, 2), ("Đăng xuất", "Đăng xuất", 3)]
        }
            
    }
    
    deinit {
//        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tbAccount.updateHeightHeader()
    }
    
    func showLoginController() {
        vcLogin.willMove(toParent: self)
        vcLogin.view.frame = self.view.bounds
        self.view.addSubview(vcLogin.view)
        self.addChild(vcLogin)
        vcLogin.didMove(toParent: self)
    }

    func showAlertChangeInfo(_ sContent: String, nType: Int) {
        guard let user = self.appDelegate.user else { return }
        var sContentShow = ""
        if nType == 0 {
            sContentShow = "Nhập họ tên"
        } else if nType == 1 {
            sContentShow = "Nhập số điện thoại"
        } else if nType == 2 {
            sContentShow = "Nhập email"
        }
        let alert = UIAlertController(title: "Thay đổi thông tin", message: sContentShow, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.text = sContent
            if nType == 2 {
                tf.keyboardType = .emailAddress
            }
        }
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Thay đổi", style: .default, handler: { [weak self](action) in
            if let tf = alert.textFields?.first {
                guard let inputData = tf.text, !inputData.isEmpty else {return}
                if nType == 2 && !user.email.isEmpty {
                    self?.showAlertUpdateEmailExist(user.email, emailNew: inputData)
                } else {
                    self?.updateData(user.userID, inputData: inputData, nType: nType)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateData(_ userID: String, inputData: String, nType: Int) {
        guard let user = self.appDelegate.user else { return }
        let userID = user.userID
        self.showProgressHUD("Cập nhật...")
        var fieldUpdate = ""
        if nType == 0 {
            fieldUpdate = "user_name"
        } else if nType == 1 {
            fieldUpdate = "phone"
        } else if nType == 2 {
            fieldUpdate = "email"
        }
        self.dbFireStore.collection(OrderFolderName.rootUser.rawValue).document(userID).updateData([fieldUpdate: inputData]) { [weak self](error) in
            self?.hideProgressHUD()
            if let error = error {
                print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error: \(error.localizedDescription)")
                self?.showErrorAlertView("Có lỗi xảy ra, vui lòng thử lại sau.", completion: {
                    
                })
            } else {
                if nType == 0 {
                    user.fullname = inputData
                } else if nType == 2 {
                    user.email = inputData
                } else {
                    user.phoneNumber = inputData
                }
                self?.setupInfoShow(user)
                Tools.saveUserInfo(user)
                
                DispatchQueue.main.async {
                    self?.tbAccount.reloadData()
                }
            }
        }
    }
    
    func showAlertUpdateEmailExist(_ emailOld: String, emailNew: String) {
        let alert = UIAlertController(title: "Thông báo", message: "Để thay đổi email bạn cần xác thực để thực hiện việc thay đổi. Mã xác thực sẽ được gửi email hiện tại: \(emailOld). ", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Hủy", style: .cancel, handler: nil)
        let continute = UIAlertAction(title: "Lấy mã", style: .default) { (action) in
            self.showAlertActiveCode(emailNew)
        }
        alert.addAction(cancel)
        alert.addAction(continute)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertActiveCode(_ email: String) {
        let alert = UIAlertController(title: "Thông báo", message: "Nhập mã xác thực trong email của bạn", preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "Mã xác thực"
        }
        let continute = UIAlertAction(title: "Tiếp tục", style: .default) { (action) in
            print("\(self.TAG) - \(#function) - \(#line) - email : \(email) - code : \(alert.textFields?.first?.text)")
        }
        alert.addAction(continute)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertLogout() -> Void {
        let alert = UIAlertController(title: "Đăng xuất", message: "Bạn muốn đăng xuất tài khoản khỏi ứng dụng?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Đăng xuất", style: .destructive, handler: { (action) in
            self.appDelegate.user = nil
            let typeAcc = (Tools.getObjectFromDefault(Tools.KEY_LOGIN_TYPE) as? Int) ?? 0
            if typeAcc == 1 {
                GIDSignIn.sharedInstance()?.signOut()
            } else if typeAcc == 2 {
                LoginManager().logOut()
            } else if typeAcc == 3 {
                
            }
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch {}
            Tools.removeUserInfo()
            self.tbAccount.isHidden = true
            self.showLoginController()
            if let header = self.tbAccount.tableHeaderView as? AccountHeaderView {
                header.imgvAvatar.image = nil
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func eventChooseChangeAvatar() {
        let vc = ListPhotosViewController(nibName: "ListPhotosViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return arrInfoUser.count
        }
        return self.appDelegate.user != nil ? 5 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let header = UIView()
        header.backgroundColor = Tools.hexStringToUIColor(hex: "#F9F9F9")
        let lblTitle = UILabel()
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(lblTitle)
        lblTitle.text = "ĐỊA CHỈ NHẬN HÀNG"
        lblTitle.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16).isActive = true
        lblTitle.centerYAnchor.constraint(equalTo: header.centerYAnchor, constant: 0).isActive = true
    
        let btnAdd = UIButton()
        btnAdd.setTitleColor(.black, for: .normal)
        btnAdd.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        btnAdd.setTitle("Sửa", for: .normal)
        btnAdd.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(btnAdd)
        btnAdd.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -12).isActive = true
        btnAdd.centerYAnchor.constraint(equalTo: header.centerYAnchor, constant: 0).isActive = true
        btnAdd.addTarget(self, action: #selector(eventChooseEditAddress(_:)), for: .touchUpInside)
        return header
    }
    
    @objc func eventChooseEditAddress(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = ChangeAddressViewController(nibName: "ChangeAddressViewController", bundle: nil)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTitleTableCell", for: indexPath) as! ShowTitleTableCell
            cell.lblTitle.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            cell.setupLeadingTitle(16)
            var sText = ""
            cell.accessoryType = .disclosureIndicator
            let item = arrInfoUser[indexPath.row]
            sText = item.1
            if sText.isEmpty {
                sText = item.0
            }
            if item.2 == 2 {
                cell.accessoryType = item.1.isEmpty ? .disclosureIndicator : .none
            }
            cell.lblTitle.text = sText
            return cell
        } else {
            let cell = tbAccount.dequeueReusableCell(withIdentifier: "AccountReceiverTableCell", for: indexPath) as! AccountReceiverTableCell
            var title = ""
            var content = ""
            if indexPath.row == 0 {
                title = "Họ tên"
                content = self.appDelegate.user?.receiverName ?? "Chưa có"
            } else if indexPath.row == 1 {
                title = "Số điện thoại"
                content = self.appDelegate.user?.receiverPhone ?? "Chưa có"
            } else if indexPath.row == 2 {
                title = "Tỉnh/Thành phố"
                content = self.appDelegate.user?.cityName ?? "Chưa có"
            } else if indexPath.row == 3 {
                title = "Quận/Huyện"
                content = self.appDelegate.user?.districtName ?? "Chưa có"
            } else if indexPath.row == 4 {
                title = "Địa chỉ nhà"
                content = self.appDelegate.user?.address ?? "Chưa có"
            }
            cell.lblTitle.text = title
            cell.lblContent.text = content
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let item = arrInfoUser[indexPath.row]
            if item.2 == 0 {
                self.showAlertChangeInfo(self.appDelegate.user?.fullname ?? "", nType: indexPath.row)
            } else if item.2 == 1 {
                self.showAlertChangeInfo(self.appDelegate.user?.phoneNumber ?? "", nType: indexPath.row)
            } else if item.2 == 2 {
                self.showAlertChangeInfo(self.appDelegate.user?.email ?? "", nType: indexPath.row)
            }
            else if item.2 == 3 {
                self.showAlertLogout()
            }
        }
    }
}
