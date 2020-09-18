//
//  ChooseDeliveryViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/16/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import Firebase

class ChooseDeliveryViewController: MainViewController {
    @IBOutlet weak var tbDelivery: UITableView!
    var arrDelivery = [DeliveryModel]() {
        didSet {
            DispatchQueue.main.async {
                self.tbDelivery.reloadData()
            }
        }
    }
    var itemSelected: DeliveryModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnChoose = UIBarButtonItem(title: "Chọn", style: .done, target: self, action: #selector(eventChooseSelected(_:)))
        self.navigationItem.rightBarButtonItem = btnChoose
        
        tbDelivery.tableFooterView = UIView(frame: .zero)
        tbDelivery.register(UINib(nibName: "ShowTitleTableCell", bundle: nil), forCellReuseIdentifier: "ShowTitleTableCell")
        self.arrDelivery.append(Tools.DELIVERY_HOME)
        connectGetDeliveryList()
    }
    
    @objc func eventChooseSelected(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_CHANGE_DELIVERY"), object: itemSelected)
        self.navigationController?.popViewController(animated: true)
    }

    func connectGetDeliveryList() {
        showProgressHUD("Lấy dữ liệu...")
        self.dbFireStore.collection("Delivery").getDocuments { [weak self](snapShot, error) in
            self?.hideProgressHUD()
            if let docments = snapShot?.documents {
                let result = docments.map { (query) -> DeliveryModel in
                    let docID = query.documentID
                    let dict = query.data()
                    return DeliveryModel(dict, id: docID)
                }
                self?.arrDelivery.append(contentsOf: result)
            }
        }
    }
}

extension ChooseDeliveryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDelivery.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ShowTitleTableCell {
            cell.setupLeadingTitle(16)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTitleTableCell", for: indexPath) as! ShowTitleTableCell
        let item = arrDelivery[indexPath.row]
        cell.lblTitle.text = item.name
        cell.accessoryType = (itemSelected?.id == item.id) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemSelected = arrDelivery[indexPath.row]
        tableView.reloadData()
    }
}
