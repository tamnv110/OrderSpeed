//
//  SupportCollectionCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/5/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class SupportCollectionCell: UICollectionViewCell {

    @IBOutlet weak var tblSupport: UITableView!
    var typeShow = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        tblSupport.tableFooterView = UIView(frame: .zero)
        tblSupport.register(UINib(nibName: "SupportTableViewCell", bundle: nil), forCellReuseIdentifier: "SupportTableViewCell")
        tblSupport.register(UINib(nibName: "BankInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BankInfoTableViewCell")
        tblSupport.delegate = self
        tblSupport.dataSource = self
    }

}

extension SupportCollectionCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeShow == 0 ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if typeShow == 1 {
            return 160
        }
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if typeShow == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupportTableViewCell", for: indexPath) as! SupportTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BankInfoTableViewCell", for: indexPath) as! BankInfoTableViewCell
            return cell
        }
        
    }
}
