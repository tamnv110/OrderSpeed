//
//  WalletViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 21/12/2020.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//
/* Type
     * 0 - Nạp tiền
     * 1 - Rút tiền
     * 2 - Thanh toán hàng
     * 3 - Hoàn tiền thừa từ đơn hàng
     */
    /* Status
     * 0 - Đang sử lý
     * 1 - Hoàn thành
     * 2 - Hủy
     */
import UIKit
import Firebase

class WalletViewController: MainViewController {

    @IBOutlet weak var tblWallet: UITableView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    
    var arrTransaction = [TransactionModel]()
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        createHeaderWallet()
        tblWallet.tableFooterView = UIView(frame: .zero)
        tblWallet.register(UINib(nibName: "WalletTransactionTableCell", bundle: nil), forCellReuseIdentifier: "WalletTransactionTableCell")
        if #available(iOS 11.0, *) {
            tblWallet.contentInsetAdjustmentBehavior = .never
        }

        updateInfoUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        connectGetInfo()
        addListernerInfoUser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.remove()
    }
    
    func updateInfoUser() {
        lblName.text = ""
        lblBalance.text = ""
        if let user = self.appDelegate.user {
            lblName.text = user.fullname
            lblBalance.text = Tools.convertCurrencyFromString(input: "\(Tools.convertCurrencyFromString(input: String(format: "%.0f", user.totalMoney)))") + " đ"
        }
    }

    func createHeaderWallet() {
        let header = WalletHeaderView.instanceFromNib()
        header.frame = CGRect(x: 0, y: 0, width: tblWallet.frame.width, height: 150)
        tblWallet.tableHeaderView = header
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let headerView = tblWallet.tableHeaderView as? WalletHeaderView {
            var headerFrame = headerView.frame
            let newHeight = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            if newHeight != headerFrame.height {
                headerFrame.size.height = newHeight
                headerView.frame = headerFrame
                tblWallet.tableHeaderView = headerView
            }
        }
    }
    
    func connectGetInfo() {
        guard let user = self.appDelegate.user else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.showProgressHUD("Lấy dữ liệu...")
            let userID = user.userID
            let dGroup = DispatchGroup()
//            dGroup.enter()
//            self.connectGetBalance(userID) {
//                dGroup.leave()
//            }
            dGroup.enter()
            self.connectGetTransaction(userID) {
                dGroup.leave()
            }
            dGroup.notify(queue: .main) {
                self.updateInfoUser()
                self.tblWallet.reloadData()
                self.hideProgressHUD()
            }
        }
        
    }
    
    func addListernerInfoUser() {
        guard let user = self.appDelegate.user else { return }
        listener = self.dbFireStore.collection(OrderFolderName.rootUser.rawValue).document(user.userID).addSnapshotListener { [weak self](snapshot, error) in
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            let source = document.metadata.hasPendingWrites ? "Local" : "Server"
            if source == "Server", let data = document.data() {
                print("\(self?.TAG ?? "") - \(#function) - \(#line) - data : \(data)")
                self?.updateUserInfo(data)
                self?.updateInfoUser()
            }
        }
    }
    
    func connectGetBalance(_ userID: String, completion: @escaping ()->()) {
        self.dbFireStore.collection(OrderFolderName.rootUser.rawValue).document(userID).getDocument { (snapshot, error) in
            if let dict = snapshot?.data() {
                self.updateUserInfo(dict)
            }
            completion()
        }
    }
    
    func updateUserInfo(_ dict: [String: Any]) {
        var sAvartar = dict["avatar"] as? String ?? ""
        if sAvartar.hasPrefix("https://graph.facebook.com") {
            sAvartar = "\(sAvartar)?type=large"
        }
        
        debugPrint("\(String(describing: self.TAG)) - \(#function) - line : \(#line) - sAvartar : \(sAvartar)")
        let user = UserBeer(id: dict["uid"] as? String ?? "", email: dict["email"] as? String ?? "", fullname: dict["user_name"] as? String ?? "", avatar: sAvartar, phoneNumber: dict["phone"] as? String ?? "", receiverPhone: dict["receiver_phone"] as? String ?? "", receiverName: dict["receiver_name"] as? String ?? "", address: dict["address"] as? String ?? "", cityName: dict["city_name"] as? String ?? "", districtName: dict["district_name"] as? String ?? "", tokenAPN: dict["apn_key"] as? String ?? "", typeAcc: dict["typeAcc"] as? Int ?? 2, totalMoney: dict["total_money"] as? Double ?? 0.0, code: dict["code"] as? String ?? "")
        Tools.saveUserInfo(user)
        self.appDelegate.user = user
    }
    
    func connectGetTransaction(_ userID: String, completion: @escaping ()->()) {
        self.arrTransaction.removeAll()
        self.dbFireStore.collection(OrderFolderName.transaction.rawValue).whereField("user_id", isEqualTo: userID).getDocuments { [weak self](snapshot, error) in
            if let documents = snapshot?.documents {
                guard let _self = self else { return }
                let decoder = JSONDecoder()
                for document in documents {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                        var result = try decoder.decode(TransactionModel.self, from: data)
                        result.idTransaction = document.documentID
                        _self.arrTransaction.append(result)
                    } catch  {
                        print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    }
                }
                _self.arrTransaction = _self.arrTransaction.sorted(by: { (item1, item2) -> Bool in
                    return item1.updateAt >= item2.updateAt
                })
            } else {
                print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error?.localizedDescription ?? "")")
            }
            completion()
        }
    }

    @IBAction func eventChooseNapTien(_ sender: Any) {
        let vc = NapTienViewController(nibName: "NapTienViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func eventChooseRutTien(_ sender: Any) {
        guard let user = self.appDelegate.user else {
            self.showAlertView("Vui lòng đăng nhập để sử dụng chức năng này.") {
                
            }
            return
        }
        if user.email.isEmpty {
            self.showAlertView("Vui lòng cập nhật email để sử dụng chức năng này.") {

            }
        } else if user.totalMoney <= 0 {
            self.showAlertView("Số dư trong ví không đủ để sử dụng chức năng này.") {

            }
        } else {
            let vc = RutTienViewController(nibName: "RutTienViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTransaction.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTransactionTableCell", for: indexPath) as! WalletTransactionTableCell
        let item = arrTransaction[indexPath.row]
        cell.showInfo(item)
        return cell
    }
}
