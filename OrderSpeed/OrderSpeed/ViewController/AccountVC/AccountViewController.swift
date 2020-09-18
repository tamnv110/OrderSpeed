//
//  AccountViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/16/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tbAccount.tableFooterView = UIView(frame: .zero)
        tbAccount.register(UINib(nibName: "ShowTitleTableCell", bundle: nil), forCellReuseIdentifier: "ShowTitleTableCell")

        if self.appDelegate.user == nil {
            tbAccount.isHidden = true
            showLoginController()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("LOGIN_FINISH"), object: nil, queue: .main) { [weak self](notification) in
            self?.vcLogin.willMove(toParent: nil)
            self?.vcLogin.view.removeFromSuperview()
            self?.vcLogin.removeFromParent() 
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func showLoginController() {
        vcLogin.willMove(toParent: self)
        vcLogin.view.frame = self.view.bounds
        self.view.addSubview(vcLogin.view)
        self.addChild(vcLogin)
        vcLogin.didMove(toParent: self)
    }

}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.appDelegate.user != nil ? 5 : 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTitleTableCell", for: indexPath) as! ShowTitleTableCell
        cell.setupLeadingTitle(16)
        var sText = ""
        if indexPath.section == 0 {
            cell.accessoryType = .disclosureIndicator
            if indexPath.row == 0 {
                sText = self.appDelegate.user?.fullname ?? ""
            } else if indexPath.row == 1 {
                sText = self.appDelegate.user?.phoneNumber ?? ""
                if sText.isEmpty {
                    sText = "Cập nhật số điện thoại"
                }
            } else if indexPath.row == 2 {
                sText = self.appDelegate.user?.email ?? ""
                if sText.isEmpty {
                    sText = "Cập nhật email"
                } else {
                    cell.accessoryType = .none
                }
            } else if indexPath.row == 3 {
                sText = self.appDelegate.user?.cityName ?? ""
                if sText.isEmpty {
                    sText = "Chọn tỉnh/thành phố"
                }
            } else if indexPath.row == 4 {
                sText = "Đổi mật khẩu"
            }
        } else {
            sText = self.appDelegate.user?.cityName ?? ""
            if sText.isEmpty {
                sText = "Bạn chưa có địa chỉ nhận hàng"
            } else {
                sText = "\(self.appDelegate.user?.address ?? ""), \(self.appDelegate.user?.districtName ?? ""), \(self.appDelegate.user?.cityName ?? "")"
            }
        }
        cell.lblTitle.text = sText
        return cell
    }
}
