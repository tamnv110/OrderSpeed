//
//  StatusOrderViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/18/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class StatusOrderViewController: MainViewController {

    @IBOutlet weak var tbStatus: UITableView!
    
    @IBOutlet weak var btnOptionJourney: UIButton!
    @IBOutlet weak var btnOptionSupport: UIButton!
    var orderProduct: OrderProductDataModel?
    var orderID: String?
    var arrProducts = [ProductModel]()
    var arrStatus = [OrderStatusModel]()
    
    var arrSupport = [RequestSupportModel]()
    
    var typeOption = 0
    var sNguoiNhan = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createHeaderStatus()
        tbStatus.tableFooterView = UIView(frame: .zero)
        tbStatus.register(UINib(nibName: "CheckOrderTableCell", bundle: nil), forCellReuseIdentifier: "CheckOrderTableCell")
        tbStatus.register(UINib(nibName: "OrderStatusTableCell", bundle: nil), forCellReuseIdentifier: "OrderStatusTableCell")
        tbStatus.isHidden = true
        if orderProduct != nil {
            self.updateRightButton()
            connectGetDetail()
        } else if let _orderID = orderID {
            connectGetOrderInfo(_orderID)
        }
    }

    @IBAction func eventChangeOption(_ sender: UIButton) {
        let arrBtn = [btnOptionJourney!, btnOptionSupport!]
        for (index, btn) in arrBtn.enumerated() {
            btn.backgroundColor = Tools.hexStringToUIColor(hex: "#EDEBEB")
            btn.setTitleColor(.black, for: .normal)
            if btn == sender {
                typeOption = index
                btn.backgroundColor = Tools.hexStringToUIColor(hex: "#EC8425")
                btn.setTitleColor(.white, for: .normal)
            }
        }
        createHeaderStatus()
        DispatchQueue.main.async {
            self.tbStatus.reloadData()
        }
        if typeOption == 1 && arrSupport.count == 0 {
            connectGetSupport()
        }
    }
    
    func createHeaderStatus() {
        if typeOption == 0 {
            let header = StatusOrderHeaderView.instanceFromNib()
            header.frame = CGRect(x: 0, y: 0, width: tbStatus.frame.width, height: 160)
            tbStatus.tableHeaderView = header
            header.lblStatus.text = orderProduct?.status
        } else {
            let header = RequestSupportHeaderView.instanceFromNib()
            header.btnSend.addTarget(self, action: #selector(eventChooseSendRequestSupport(_:)), for: .touchUpInside)
            header.frame = CGRect(x: 0, y: 0, width: tbStatus.frame.width, height: 250)
            tbStatus.tableHeaderView = header
        }
    }
    
    func updateRightButton() {
        guard let order = self.orderProduct else { return }
        print("\(TAG) - \(#function) - \(#line) - order.depositMoney : \(order.depositMoney)")
        if order.status.lowercased() != "đã hủy"{
            let btnCancel = UIButton()
            btnCancel.addTarget(self, action: #selector(eventChooseCancelOrder(_:)), for: .touchUpInside)
            btnCancel.setTitle("Hủy đơn", for: .normal)
            btnCancel.setTitleColor(.red, for: .normal)
            btnCancel.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            let btnRight = UIBarButtonItem(customView: btnCancel)
            self.navigationItem.rightBarButtonItem = btnRight
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc func eventChooseCancelOrder(_ sender: Any) {
        print("\(TAG) - \(#function) - \(#line) - click click")
        guard let order = orderProduct else { return }
        let alert = UIAlertController(title: "Thông báo", message: "Bạn muốn hủy đơn hàng \(order.code)?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Không", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Hủy đơn", style: .destructive) { (action) in
            self.connectCancelOrder(order)
        }
        alert.addAction(cancel)
        alert.addAction(yes)
        self.present(alert, animated: true, completion: nil)
    }
    
    func connectCancelOrder(_ order: OrderProductDataModel) {
        self.showProgressHUD("Huỷ đơn hàng...")
        self.dbFireStore.collection(OrderFolderName.rootStatus.rawValue).order(by: "sort", descending: true).getDocuments { [weak self](snapshot, error) in
            if let documents = snapshot?.documents {
                do {
                    if let document = try documents.first(where: { (doc) -> Bool in
                        let jsonData = try JSONSerialization.data(withJSONObject: doc.data(), options: [])
                        let result = try JSONDecoder().decode(OrderStatusModel.self, from: jsonData)
                        return result.name.lowercased() == "đã hủy"
                    }) {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                            let result = try JSONDecoder().decode(OrderStatusModel.self, from: jsonData)
                            self?.updateCancelOrder(order, status: result)
                        } catch {
                            self?.showErrorCancel()
                        }
                    } else {
                        self?.showErrorCancel()
                    }
                } catch  {
                    self?.showErrorCancel()
                }
            } else {
                self?.showErrorCancel()
            }
        }
    }
    
    func updateCancelOrder(_ order: OrderProductDataModel, status: OrderStatusModel) {
        let batch = self.dbFireStore.batch()
        let orderRef = self.dbFireStore.collection(OrderFolderName.rootOrderProduct.rawValue).document(order.idOrder!)
        let statusRef = orderRef.collection(OrderFolderName.status.rawValue).document()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeUpdate = formatter.string(from: Date())
        
        var statusCancel = status
        statusCancel.createAt = timeUpdate
        batch.updateData(["status": statusCancel.name, "update_at": timeUpdate], forDocument: orderRef)
        batch.setData(statusCancel.dictionary, forDocument: statusRef)
        batch.commit { [weak self](error) in
            if let _ = error {
                self?.showErrorCancel()
            } else {
                self?.navigationItem.rightBarButtonItem = nil
                self?.hideProgressHUD()
                self?.showAlertView("Hủy đơn hàng thành công.", completion: {
                    NotificationCenter.default.post(name: NSNotification.Name("HUY_DON_HANG"), object: nil)
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    
    func showErrorCancel() {
        self.hideProgressHUD()
        self.showErrorAlertView("Có lỗi xảy ra, vui lòng thử lại sau.") {
            
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tbStatus.updateHeightHeader()
    }
    
    func connectGetOrderInfo(_ orderID: String) -> Void {
        print("\(TAG) - \(#function) - \(#line) - orderID : \(orderID)")
        self.showProgressHUD("Lấy chi tiết...")
        self.dbFireStore.collection(OrderFolderName.rootOrderProduct.rawValue).document(orderID).getDocument { [weak self](snapshot, error) in
            self?.hideProgressHUD()
            if let data = snapshot?.data() {
                do {
                    let decoder = JSONDecoder()
                    let data = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    var result = try decoder.decode(OrderProductDataModel.self, from: data)
                    result.idOrder = orderID
                    self?.orderProduct = result
                    print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - orderProduct : \(String(describing: self?.orderProduct?.idOrder)) - \(String(describing: self?.orderProduct?.status))")
                    self?.createHeaderStatus()
                    self?.updateRightButton()
                    self?.connectGetDetail()
                } catch  {
                    self?.showErrorAlertView("Có lỗi xảy ra, vui lòng thử lại sau.", completion: {
                        
                    })
                }
            } else {
                self?.showErrorAlertView("Có lỗi xảy ra, vui lòng thử lại sau.", completion: {
                    
                })
            }
        }
    }
    
    func connectGetDetail() {
        guard let order = orderProduct, let orderID = order.idOrder else {
            return
        }
        
        self.showProgressHUD("Lấy chi tiết...")
        let collectionStatusRef = self.dbFireStore.collection(OrderFolderName.rootOrderProduct.rawValue).document(orderID).collection(OrderFolderName.status.rawValue)
        
        connectGetProduct(orderID) { [weak self](result, error) in
            if result.count > 0 {
                self?.arrProducts.append(contentsOf: result)
            }
            collectionStatusRef.order(by: "create_at", descending: true).getDocuments { [weak self](statusSnapshot, error) in
                self?.hideProgressHUD()
                if let documents = statusSnapshot?.documents {
                    documents.forEach { (document) in
                        do {
                            let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                            var result = try JSONDecoder().decode(OrderStatusModel.self, from: data)
                            result.statusID = document.documentID
                            self?.arrStatus.append(result)
                        } catch{}
                    }
                    print("\(self?.TAG) - \(#function) - \(#line) - self?.arrStatus : \(String(describing: self?.arrStatus.count))")
                }
                DispatchQueue.main.async {
                    self?.tbStatus.isHidden = false
                    self?.tbStatus.reloadData()
                }
            }
        }
        
    }
    
    func connectGetSupport() {
        guard let order = orderProduct, let orderID = order.idOrder else {
            return
        }
        self.showProgressHUD("Lấy thông tin...")
        let docRef: Void = self.dbFireStore.collection(OrderFolderName.rootRequestSupport.rawValue).whereField("order_id", isEqualTo: orderID).getDocuments { [weak self](snapshot, error) in
            self?.hideProgressHUD()
            if let documents = snapshot?.documents {
                let decoder = JSONDecoder()
                documents.forEach { (document) in
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                        var result = try decoder.decode(RequestSupportModel.self, from: data)
                        result.idRequest = document.documentID
                        self?.arrSupport.append(result)
                    } catch  {
                        print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    }
                }
                DispatchQueue.main.async {
                    self?.tbStatus.reloadData()
                }
            }
        }
    }
    
    @objc func eventChooseSendRequestSupport(_ sender: Any) {
        guard let header = tbStatus.tableHeaderView as? RequestSupportHeaderView else { return }
        if header.checkDataInpunt() {
            DispatchQueue.main.async {
                self.view.endEditing(true)
            }
            guard let user = self.appDelegate.user, let orderID = orderProduct?.idOrder else { return }
            self.showProgressHUD("Gửi hỗ trợ...")
            let item = RequestSupportModel(user.userID, userName: user.fullname, userPhone: user.phoneNumber, title: header.tfTitle.text ?? "", content: header.tfContent.text, orderID: orderID)
            self.dbFireStore.collection("RequestSupport").addDocument(data: item.dictionary) { [weak self](error) in
                self?.hideProgressHUD()
                if let _ = error {
                    self?.showErrorAlertView("Có lỗi xảy ra, vui lòng thử lại sau."){}
                } else {
                    self?.arrSupport.append(item)
                    self?.showAlertView("Gửi yêu cầu hỗ trợ thành công. Chúng tôi sẽ phản hồi bạn sớm nhất.", completion: {
                        self?.dismiss(animated: true, completion: nil)
                    })
                    DispatchQueue.main.async {
                        self?.tbStatus.reloadData()
                    }
                }
            }
        }
    }
    
}

extension StatusOrderViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return typeOption == 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if typeOption == 0 {
            if section == 0 {
                return arrStatus.count
            } else if section == 1 {
                return arrProducts.count
            }
        } else {
            return arrSupport.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.0001
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            if orderProduct != nil {
                return 270
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            if let order = orderProduct {
                let header = DetailOrderStatusSectionView.instanceFromNib()
                header.showInfo(order)
                return header
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if typeOption == 0 && section != 0 {
            return 150
        }
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if typeOption == 0 && section != 0 {
            let footer = UIView()
            let lblNguoiNhan = UILabel()
            lblNguoiNhan.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            lblNguoiNhan.text = "người nhận".uppercased()
            lblNguoiNhan.translatesAutoresizingMaskIntoConstraints = false
            footer.addSubview(lblNguoiNhan)
            lblNguoiNhan.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 16).isActive = true
            lblNguoiNhan.topAnchor.constraint(equalTo: footer.topAnchor, constant: 8).isActive = true
            
            let lblTen = UILabel()
            lblTen.font = UIFont.systemFont(ofSize: 15)
            lblTen.text = "Người nhận: \(orderProduct?.receiverName ?? "")"
            lblTen.translatesAutoresizingMaskIntoConstraints = false
            footer.addSubview(lblTen)
            lblTen.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 16).isActive = true
            lblTen.topAnchor.constraint(equalTo: lblNguoiNhan.bottomAnchor, constant: 8).isActive = true
            lblTen.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -8).isActive = true
            
            let lblDC = UILabel()
            lblDC.font = UIFont.systemFont(ofSize: 15)
            lblDC.numberOfLines = 3
            var address = orderProduct?.receiverAddress ?? ""
            let dictrictName = orderProduct?.districtName ?? ""
            if !dictrictName.isEmpty {
                address.append(", \(dictrictName)")
            }
            let cityName = orderProduct?.cityName ?? ""
            if !cityName.isEmpty {
                address.append(", \(cityName)")
            }
            lblDC.text = "Người nhận: \(address)"
            lblDC.translatesAutoresizingMaskIntoConstraints = false
            footer.addSubview(lblDC)
            lblDC.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 16).isActive = true
            lblDC.topAnchor.constraint(equalTo: lblTen.bottomAnchor, constant: 8).isActive = true
            lblDC.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -8).isActive = true
            return footer
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if typeOption == 0 {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusTableCell", for: indexPath) as! OrderStatusTableCell
                let item = arrStatus[indexPath.row]
                cell.showInfo(item)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckOrderTableCell", for: indexPath) as! CheckOrderTableCell
//            cell.isShadow = false
            cell.lblTitle.text = "SẢN PHẨM \(indexPath.row + 1)"
            let item = arrProducts[indexPath.row]
            cell.product = item
            if (item.arrProductImages?.count ?? 0 == 0) && (item.images?.count ?? 0 == 0) {
                cell.heightCollectionImages.constant = 0
            } else {
                cell.heightCollectionImages.constant = cell.heightCollectionOld
                cell.refStorage = self.storageRef
            }
            cell.btnEdit.isHidden = true
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusTableCell", for: indexPath) as! OrderStatusTableCell
            let item = arrSupport[indexPath.row]
            cell.showInfoSupport(item)
            return cell
        }
    }
}
