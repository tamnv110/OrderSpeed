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
    var orderProduct: OrderProductDataModel?
    var arrProducts = [ProductModel]()
    var arrStatus = [OrderStatusModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createHeaderStatus()
        tbStatus.tableFooterView = UIView(frame: .zero)
        tbStatus.register(UINib(nibName: "CheckOrderTableCell", bundle: nil), forCellReuseIdentifier: "CheckOrderTableCell")
        tbStatus.register(UINib(nibName: "OrderStatusTableCell", bundle: nil), forCellReuseIdentifier: "OrderStatusTableCell")
        tbStatus.isHidden = true
        connectGetDetail()
    }

    func createHeaderStatus() {
        let header = StatusOrderHeaderView.instanceFromNib()
        header.frame = CGRect(x: 0, y: 0, width: tbStatus.frame.width, height: 160)
        tbStatus.tableHeaderView = header
        header.lblStatus.text = orderProduct?.status
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tbStatus.updateHeightHeader()
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
            collectionStatusRef.getDocuments { [weak self](statusSnapshot, error) in
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
    
}

extension StatusOrderViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return arrStatus.count
        } else if section == 1 {
            return arrProducts.count
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
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusTableCell", for: indexPath) as! OrderStatusTableCell
            let item = arrStatus[indexPath.row]
            cell.showInfo(item)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckOrderTableCell", for: indexPath) as! CheckOrderTableCell
        let item = arrProducts[indexPath.row]
        cell.product = item
        if item.images?.count == 0 {
            cell.heightCollectionImages.constant = 0
        } else {
            cell.refStorage = self.storageRef
        }
        cell.btnEdit.isHidden = true
        return cell
    }
}
