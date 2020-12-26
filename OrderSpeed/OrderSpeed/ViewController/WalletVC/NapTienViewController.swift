//
//  NapTienViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 23/12/2020.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class NapTienViewController: MainViewController {
    @IBOutlet weak var tblNapTien: UITableView!
    var arrBank = [BankInfoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Nạp tiền vào ví"
        tblNapTien.register(UINib(nibName: "SupportMainCell", bundle: nil), forCellReuseIdentifier: "SupportMainCell")
        tblNapTien.tableFooterView = UIView(frame: .zero)
        connectGetBank()
    }
    
    func connectGetBank() {
        self.dbFireStore.collection(OrderFolderName.rootBank.rawValue).limit(to: 6).order(by: "sort", descending: false).getDocuments { [weak self](snapshot, error) in
            if let documents = snapshot?.documents {
                let decoder = JSONDecoder()
                for document in documents {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                        let result = try decoder.decode(BankInfoModel.self, from: data)
                        self?.arrBank.append(result)
                    } catch  {
                        print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    }
                }
            }
            DispatchQueue.main.async {
                self?.tblNapTien.reloadData()
            }
        }
    }
}

extension NapTienViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 390.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 240
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = WalletHeaderView.instanceFromNib()
        return header
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SupportMainCell {
            arrBank.count == 0 ? cell.loadingView.startAnimating() : cell.loadingView.stopAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SupportMainCell {
            cell.loadingView.stopAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupportMainCell", for: indexPath) as! SupportMainCell
        cell.typeShow = 1
        cell.arrInfo = arrBank
        if arrBank.count > 0 {
            cell.viewLoading.isHidden = true
        } else {
            cell.viewLoading.isHidden = false
        }
        return cell
    }
}
