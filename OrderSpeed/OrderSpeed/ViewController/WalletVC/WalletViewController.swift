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

class WalletViewController: MainViewController {

    @IBOutlet weak var tblWallet: UITableView!
    var arrTransaction = [TransactionModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        createHeaderWallet()
        tblWallet.tableFooterView = UIView(frame: .zero)
        tblWallet.register(UINib(nibName: "WalletTransactionTableCell", bundle: nil), forCellReuseIdentifier: "WalletTransactionTableCell")
        if #available(iOS 11.0, *) {
            tblWallet.contentInsetAdjustmentBehavior = .never
        }
        connectGetTransaction()
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
    
    func connectGetTransaction() {
        guard let user = self.appDelegate.user else { return }
        self.showProgressHUD("Lấy dữ liệu...")
        var userID = user.userID
        #if DEBUG
            userID = "03t0Cl73pVRlhJzdXVH0DVWnKkP2"
        #endif
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
            
            DispatchQueue.main.async {
                self?.tblWallet.reloadData()
                self?.hideProgressHUD()
            }
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
