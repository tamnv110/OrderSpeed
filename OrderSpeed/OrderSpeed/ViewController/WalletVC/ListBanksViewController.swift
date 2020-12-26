//
//  ListBanksViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 25/12/2020.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import SwiftyJSON

class ListBanksViewController: MainViewController {

    @IBOutlet weak var tblBank: UITableView!
    var arrBanks = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Chọn ngân hàng"
        tblBank.tableFooterView = UIView(frame: .zero)
        tblBank.register(UINib(nibName: "ShowTitleTableCell", bundle: nil), forCellReuseIdentifier: "ShowTitleTableCell")
        getListBanks()
    }


    func getListBanks() {
        if let path = Bundle.main.path(forResource: "banks_goc", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let json = try JSON(data: data)
                if let result = json["banks"].array {
                    self.arrBanks.append(contentsOf: result)
                    DispatchQueue.main.async {
                        
                    }
                }
            } catch {
                print("\(TAG) - \(#function) - \(#line) - error : \(error.localizedDescription)")
            }
        }
    }

}

extension ListBanksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrBanks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTitleTableCell", for: indexPath) as! ShowTitleTableCell
        let item = arrBanks[indexPath.row]
        cell.leadingTitle.constant = 16
        cell.lblTitle.text = item["NAME_VI"].string
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrBanks[indexPath.row]
        NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_CHOOSE_BANK"), object: item["NAME_VI"].stringValue)
        self.navigationController?.popViewController(animated: true)
    }
}
