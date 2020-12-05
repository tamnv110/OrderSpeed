//
//  ManagerOrderViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/16/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import Firebase

class ManagerOrderViewController: MainViewController {

    @IBOutlet weak var tbOrder: UITableView!
    var arrOrders = [OrderProductDataModel]()
    var listener: ListenerRegistration?
    var statusSelected = OrderStatusModel("Tất cả", name: "Tất cả", slug: "", sort: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ""
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Quản lý đơn hàng", style: .done, target: nil, action: nil)
        
//        let btnAdd = UIButton(type: .custom)
//        btnAdd.addTarget(self, action: #selector(eventChooseAddOrder(_:)), for: .touchUpInside)
//        btnAdd.setTitleColor(.white, for: .normal)
//        btnAdd.setTitle("Thêm", for: .normal)
//        btnAdd.setImage(UIImage(named: "icon_cart"), for: .normal)
//        btnAdd.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
//
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
//        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#DC7942").cgColor, Tools.hexStringToUIColor(hex: "#F8AB25").cgColor]
//        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
//        btnAdd.layer.insertSublayer(gradientLayer, below: btnAdd.imageView?.layer)
//
//
//        let btnRight = UIBarButtonItem(customView: btnAdd)
//        btnRight.customView?.widthAnchor.constraint(equalToConstant: 120).isActive = true
//        btnRight.customView?.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        btnRight.customView?.clipsToBounds = true
//        btnRight.customView?.layer.cornerRadius = 20
//        self.navigationItem.rightBarButtonItem = btnRight
        
        tbOrder.tableFooterView = UIView(frame: .zero)
        tbOrder.register(UINib(nibName: "ManagerOrderTableCell", bundle: nil), forCellReuseIdentifier: "ManagerOrderTableCell")
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("HUY_DON_HANG"), object: nil, queue: .main) { (notification) in
            self.arrOrders.removeAll()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        addListenerManagerOrder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    
    func addListenerManagerOrder() {
        print("\(TAG) - \(#function) - \(#line) ===============> START")
        if let user = self.appDelegate.user {
            if self.arrOrders.count == 0 {
                showProgressHUD("Lấy dữ liệu...")
            }
            var query = self.dbFireStore.collection(OrderFolderName.rootOrderProduct.rawValue)
                .whereField("user_id", isEqualTo: user.userID)
                .order(by: "created_at", descending: true)
            if statusSelected.name.lowercased() != "tất cả" {
                query = self.dbFireStore.collection(OrderFolderName.rootOrderProduct.rawValue)
                    .whereField("user_id", isEqualTo: user.userID).whereField("status", isEqualTo: statusSelected.name)
                    .order(by: "created_at", descending: true)
            }
            listener = query.addSnapshotListener { [weak self](snapshot, error) in
                if let docments = snapshot {
                    docments.documentChanges.forEach({ (diff) in
                        if (diff.type == .added) {
                            self?.addOrderProduct(diff.document.documentID, dict: diff.document.data())
                        } else if (diff.type == .modified) {
                            self?.updateOrderProduct(diff.document.documentID, dict: diff.document.data())
                        }else if (diff.type == .removed) {
                            self?.removeOrderProduct(diff.document.documentID)
                        }

                    })
                    DispatchQueue.main.async {
                        self?.tbOrder.reloadData()
                    }
                    self?.hideProgressHUD()
                }
            }
        } else {
            let lblFooter = UILabel(frame: tbOrder.bounds)
            lblFooter.textAlignment = .center
            lblFooter.text = "Bạn cần đăng nhập để quản lý đơn hàng."
            lblFooter.textColor = UIColor.darkGray
            tbOrder.tableFooterView = lblFooter
        }
    }
    
    func addOrderProduct(_ orderID: String, dict: [String: Any]) {
        print("\(TAG) - \(#function) - \(#line) - orderID : \(orderID)")
        if arrOrders.firstIndex(where: { (order) -> Bool in
            return order.idOrder == orderID
        }) == nil {
            let decoder = JSONDecoder()
            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                var result = try decoder.decode(OrderProductDataModel.self, from: data)
                result.idOrder = orderID
                self.arrOrders.append(result)
            } catch  {
                print("\(self.TAG) - \(#function) - \(#line) - error : \(error.localizedDescription)")
            }
        }
    }
    
    func updateOrderProduct(_ orderID: String, dict: [String: Any]) {
        print("\(TAG) - \(#function) - \(#line) - orderID : \(orderID)")
        if let index = arrOrders.firstIndex(where: { (order) -> Bool in
            return order.idOrder == orderID
        }) {
            print("\(TAG) - \(#function) - \(#line) - index : \(index)")
            let decoder = JSONDecoder()
            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                var result = try decoder.decode(OrderProductDataModel.self, from: data)
                result.idOrder = orderID
                arrOrders[index] = result
            } catch {
            }
        }
    }
    
    func removeOrderProduct(_ orderID: String) {
        if let index = arrOrders.firstIndex(where: { (order) -> Bool in
            return order.idOrder == orderID
        }) {
            self.arrOrders.remove(at: index)
        }
    }
    
    func connectGetOrderList() {
        guard let user = self.appDelegate.user else { return }
        self.arrOrders.removeAll()
        self.showProgressHUD("Lấy dữ liệu...")
        var query = self.dbFireStore.collection(OrderFolderName.rootOrderProduct.rawValue).whereField("user_id", isEqualTo: user.userID)
        if statusSelected.name.lowercased() != "tất cả" {
            query = self.dbFireStore.collection(OrderFolderName.rootOrderProduct.rawValue).whereField("user_id", isEqualTo: user.userID).whereField("status", isEqualTo: statusSelected.name)
        }
        query.getDocuments { [weak self](snapshot, error) in
            self?.hideProgressHUD()
            if let documents = snapshot?.documents {
                let decoder = JSONDecoder()
                for document in documents {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                        var result = try decoder.decode(OrderProductDataModel.self, from: data)
                        result.idOrder = document.documentID
                        self?.arrOrders.append(result)
                    } catch  {
                        print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    }
                }
                DispatchQueue.main.async {
                    self?.tbOrder.reloadData()
                }
            } else {
            }
        }
    }

    @objc func eventChooseAddOrder(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = CreateOrderViewController(nibName: "CreateOrderViewController", bundle: nil)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func eventChooseSupport(_ sender: UIButton) {
        if let cell = sender.superview?.superview?.superview as? ManagerOrderTableCell, let indexPath = tbOrder.indexPath(for: cell) {
            let order = arrOrders[indexPath.row]
            DispatchQueue.main.async {
                let vc = RequestSupportViewController(nibName: "RequestSupportViewController", bundle: nil)
                vc.order = order
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @objc func eventChooseEditOrder(_ sender: UIButton) {
        if let cell = sender.superview?.superview?.superview as? ManagerOrderTableCell, let indexPath = tbOrder.indexPath(for: cell) {
            let order = arrOrders[indexPath.row]
            if order.depositMoney > 0 {
                DispatchQueue.main.async {
                    let alertVC = UIAlertController(title: "Thông báo", message: "Bạn muốn hủy đơn hàng: \(order.code)?", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Không", style: .cancel, handler: nil)
                    let delete = UIAlertAction(title: "Hủy đơn", style: .destructive) { (action) in
                        self.connectCancelOrder(order)
                    }
                    alertVC.addAction(cancel)
                    alertVC.addAction(delete)
                    self.present(alertVC, animated: true, completion: nil)
                }
            } else {
                if order.status.lowercased() == "Đã hủy" {
                    DispatchQueue.main.async {
                        let vc = OrderInfoViewController(nibName: "OrderInfoViewController", bundle: nil)
                        vc.typeEdit = 1
                        vc.orderEdit = order
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    func connectCancelOrder(_ order: OrderProductDataModel) {
        self.showProgressHUD("Huỷ đơn hàng...")
        self.dbFireStore.collection(OrderFolderName.rootStatus.rawValue).order(by: "sort", descending: true).getDocuments { [weak self](snapshot, error) in
            if let documents = snapshot?.documents, let document = documents.first {
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
                self?.hideProgressHUD()
                self?.showAlertView("Hủy đơn hàng thành công.", completion: {
                    
                })
            }
        }
    }
    
    func showErrorCancel() {
        self.hideProgressHUD()
        self.showErrorAlertView("Có lỗi xảy ra, vui lòng thử lại sau.") {
            
        }
    }
    
    @objc func eventChooseOption(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = OrderStatusOptionViewController(nibName: "OrderStatusOptionViewController", bundle: nil)
            vc.itemSelected = self.statusSelected
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension ManagerOrderViewController: OrderStatusOptionDelegate {
    func eventChooseStatus(_ status: OrderStatusModel) {
        self.statusSelected = status
        arrOrders.removeAll()
        DispatchQueue.main.async {
            self.tbOrder.reloadData()
        }
        listener?.remove()
        addListenerManagerOrder()
    }
}

extension ManagerOrderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOrders.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = Tools.hexStringToUIColor(hex: "#F2F2F7")
        let lblTitle = UILabel()
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(lblTitle)
        lblTitle.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16).isActive = true
        lblTitle.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        lblTitle.text = self.statusSelected.name
        
        let btnMore = UIButton()
        btnMore.addTarget(self, action: #selector(eventChooseOption(_:)), for: .touchUpInside)
        btnMore.setImage(UIImage(named: "icon_accessory_cell"), for: .normal)
        btnMore.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(btnMore)
        btnMore.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        btnMore.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: 0).isActive = true
        btnMore.widthAnchor.constraint(equalToConstant: 40).isActive = true
        btnMore.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManagerOrderTableCell", for: indexPath) as! ManagerOrderTableCell
        cell.showInfo(arrOrders[indexPath.row])
        cell.btnSupport.addTarget(self, action: #selector(eventChooseSupport(_:)), for: .touchUpInside)
        cell.btnEdit.addTarget(self, action: #selector(eventChooseEditOrder(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = arrOrders[indexPath.row]
        DispatchQueue.main.async {
            let vc = StatusOrderViewController(nibName: "StatusOrderViewController", bundle: nil)
            vc.orderProduct = order
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
