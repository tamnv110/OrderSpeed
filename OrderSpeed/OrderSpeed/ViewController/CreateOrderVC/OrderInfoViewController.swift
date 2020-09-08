//
//  OrderInfoViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/8/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class OrderInfoViewController: MainViewController {

    @IBOutlet weak var tbInfo: UITableView!
    var arrOrder = [OrderProductModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tbInfo.register(UINib(nibName: "ReceiverInfoTableCell", bundle: nil), forCellReuseIdentifier: "ReceiverInfoTableCell")
    }

}

extension OrderInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return arrOrder.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverInfoTableCell", for: indexPath) as! ReceiverInfoTableCell
        return cell
    }
}
