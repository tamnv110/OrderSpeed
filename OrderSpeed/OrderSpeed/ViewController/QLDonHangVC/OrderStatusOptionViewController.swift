//
//  OrderStatusOptionViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 10/5/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

protocol OrderStatusOptionDelegate {
    func eventChooseStatus(_ status: OrderStatusModel)
}

class OrderStatusOptionViewController: MainViewController {
    
    @IBOutlet weak var tbStatus: UITableView!
    var arrStatus = [OrderStatusModel]()
    var delegate: OrderStatusOptionDelegate?
    var indexSelected = 0
    var itemSelected: OrderStatusModel?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrStatus.append(OrderStatusModel("Tất cả", name: "Tất cả", slug: "", sort: 0))
        tbStatus.tableFooterView = UIView(frame: .zero)
        tbStatus.register(UINib(nibName: "ShowTitleTableCell", bundle: nil), forCellReuseIdentifier: "ShowTitleTableCell")
        connectGetStatus()
    }

    func connectGetStatus() {
        self.showProgressHUD("Lấy dữ liệu...")
        self.dbFireStore.collection(OrderFolderName.rootStatus.rawValue).order(by: "sort", descending: true).getDocuments { [weak self](snapshot, error) in
            self?.hideProgressHUD()
            if let documents = snapshot?.documents {
                documents.forEach { (document) in
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        let result = try JSONDecoder().decode(OrderStatusModel.self, from: jsonData)
                        self?.arrStatus.append(result)
                    } catch {
                        self?.showError()
                    }
                }
                if let _item = self?.itemSelected {
                    if let index = self?.arrStatus.firstIndex(where: { (item) -> Bool in
                        return item.sort == _item.sort
                    }) {
                        self?.indexSelected = index
                    }
                }
                DispatchQueue.main.async {
                    self?.tbStatus.reloadData()
                }
            } else {
                self?.showError()
            }
        }
    }

    func showError() {
        self.showErrorAlertView("Có lỗi xảy ra, vui lòng thử lại sau.") {}
    }
    
    @IBAction func eventChooseClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func eventChooseStatus(_ sender: Any) {
        let item = arrStatus[indexSelected]
        self.dismiss(animated: true) {
            self.delegate?.eventChooseStatus(item)
        }
    }
}

extension OrderStatusOptionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrStatus.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTitleTableCell", for: indexPath) as! ShowTitleTableCell
        let item = arrStatus[indexPath.row]
        cell.lblTitle.text = item.name
        cell.setupLeadingTitle(16)
        cell.accessoryType = (indexPath.row == indexSelected) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexSelected = indexPath.row
        tableView.reloadData()
    }
}
