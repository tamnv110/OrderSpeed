//
//  ListInfomationViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 10/1/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class ListInfomationViewController: MainViewController {

    @IBOutlet weak var tbInfo: UITableView!
    
    var typeInfo: NewsType = .news
    var arrInfo = [InformationModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbInfo.tableFooterView = UIView(frame: .zero)
        tbInfo.register(UINib(nibName: "ListInfomationTableCell", bundle: nil), forCellReuseIdentifier: "ListInfomationTableCell")
        connectGetListInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if typeInfo == .news {
            self.navigationItem.title = "Tin tức"
        } else if typeInfo == .guide {
            self.navigationItem.title = "Hướng dẫn"
        } else {
            self.navigationItem.title = "Thông báo"
        }
    }
    
    func connectGetListInfo() {
        self.showProgressHUD("Lấy thông tin...")
        self.dbFireStore.collection(OrderFolderName.rootNews.rawValue).whereField("type", isEqualTo: typeInfo.rawValue).order(by: "time", descending: true).getDocuments { [weak self](snapshot, error) in
            self?.hideProgressHUD()
            if let documents = snapshot?.documents {
                let decoder = JSONDecoder()
                documents.forEach { (document) in
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                        var result = try decoder.decode(InformationModel.self, from: data)
                        if self?.typeInfo == .news {
                            result.colorStart = Tools.hexStringToUIColor(hex: "#BD3A52")
                            result.colorEnd = Tools.hexStringToUIColor(hex: "#FED182")
                        } else {
                            result.colorStart = Tools.hexStringToUIColor(hex: "#3D73C5")
                            result.colorEnd = Tools.hexStringToUIColor(hex: "#4C9F95")
                        }
                        self?.arrInfo.append(result)
                    } catch  {
                        print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    }
                }
                DispatchQueue.main.async {
                    self?.tbInfo.reloadData()
                }
            }
        }
    }

}

extension ListInfomationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrInfo.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListInfomationTableCell", for: indexPath) as! ListInfomationTableCell
        let item = arrInfo[indexPath.row]
        cell.showInfo(item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrInfo[indexPath.row]
        DispatchQueue.main.async {
            let vc = DetailInfomationViewController(nibName: "DetailInfomationViewController", bundle: nil)
            vc.infomation = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
