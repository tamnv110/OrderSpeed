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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createHeaderStatus()
        tbStatus.tableFooterView = UIView(frame: .zero)
        tbStatus.register(UINib(nibName: "CheckOrderTableCell", bundle: nil), forCellReuseIdentifier: "CheckOrderTableCell")
        tbStatus.register(UINib(nibName: "OrderStatusTableCell", bundle: nil), forCellReuseIdentifier: "OrderStatusTableCell")
        tbStatus.isHidden = true
        if orderProduct != nil {
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
                    print("\(self?.TAG) - \(#function) - \(#line) - orderProduct : \(self?.orderProduct?.idOrder) - \(self?.orderProduct?.status)")
                    self?.createHeaderStatus()
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
                    print("\(self?.TAG) - \(#function) - \(#line) - self?.arrStatus : \(self?.arrStatus.count)")
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
        let docRef = self.dbFireStore.collection(OrderFolderName.rootRequestSupport.rawValue).whereField("order_id", isEqualTo: orderID).getDocuments { [weak self](snapshot, error) in
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
        return typeOption == 0 ? 3 : 1
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if typeOption == 0 {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusTableCell", for: indexPath) as! OrderStatusTableCell
                let item = arrStatus[indexPath.row]
                cell.showInfo(item)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckOrderTableCell", for: indexPath) as! CheckOrderTableCell
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
