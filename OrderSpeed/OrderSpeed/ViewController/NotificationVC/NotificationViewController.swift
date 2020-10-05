//
//  NotificationViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 10/1/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class NotificationViewController: MainViewController {

    @IBOutlet weak var lblThongBao: UILabel!
    @IBOutlet weak var tbNotification: UITableView!
    
    var arrNotification = [NotificationModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblThongBao.isHidden = (self.appDelegate.user == nil) ? false :  true
        tbNotification.tableFooterView = UIView(frame: .zero)
        tbNotification.register(UINib(nibName: "NotificationTableCell", bundle: nil), forCellReuseIdentifier: "NotificationTableCell")
        connectGetNotification()
    }


    func connectGetNotification() {
        guard let user = self.appDelegate.user else { return }
        showProgressHUD("Lấy thông báo...")
        self.dbFireStore.collection(OrderFolderName.rootUser.rawValue).document(user.userID).collection(OrderFolderName.notification.rawValue).order(by: "create_at", descending: true).getDocuments { [weak self](snapshot, error) in
            self?.hideProgressHUD()
            if let documents = snapshot?.documents {
                let decoder = JSONDecoder()
                documents.forEach { (document) in
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                        let result = try decoder.decode(NotificationModel.self, from: data)
                        self?.arrNotification.append(result)
                    } catch  {
                        print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    }
                }
                DispatchQueue.main.async {
                    self?.tbNotification.reloadData()
                }
            }
        }
    }
    
    
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNotification.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableCell", for: indexPath) as! NotificationTableCell
        let item = arrNotification[indexPath.row]
        cell.showInfo(item)
        return cell
    }
}
