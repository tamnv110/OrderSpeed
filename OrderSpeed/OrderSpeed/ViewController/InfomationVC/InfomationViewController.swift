//
//  InfomationViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/22/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

enum NewsType: Int {
    case news = 1
    case guide = 2
    case notification = 3
    case temp
}

class InfomationViewController: MainViewController {

    @IBOutlet weak var tbInfomation: UITableView!
    var arrNews: [InformationModel]?
    var arrGuide: [InformationModel]?
    
    var arrInfomation = [[InformationModel]]()
    
    var completion = (false, false, false) {
        didSet {
            if completion.0 && completion.1 && completion.2 {
                print("\(TAG) - \(#function) - \(#line) - START : \(self.arrInfomation.count)")
                self.arrInfomation.sort { (item1, item2) -> Bool in
                    var flag = true
                    if let sub1 = item1.first, let sub2 = item2.first {
                        flag = (sub1.type <= sub2.type)
                    }
                    return flag
                }
                DispatchQueue.main.async {
                    self.tbInfomation.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Thông tin", style: .done, target: nil, action: nil)
        
        tbInfomation.register(UINib(nibName: "SupportMainCell", bundle: nil), forCellReuseIdentifier: "SupportMainCell")
        
        connectGetInfomation(.news) { (items) -> (Void) in
            self.arrInfomation.append(items)
            self.completion.0 = true
        }
        
        connectGetInfomation(.guide) { (items) -> (Void) in
            self.arrInfomation.append(items)
            self.completion.1 = true
        }
        
        connectGetInfomation(.notification) { (items) -> (Void) in
            self.arrInfomation.append(items)
            self.completion.2 = true
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_SHOW_INFO"), object: nil, queue: .main) { (notification) in
            if let itemInfo = notification.object as? InformationModel {
                DispatchQueue.main.async {
                    let vc = DetailInfomationViewController(nibName: "DetailInfomationViewController", bundle: nil)
                    vc.infomation = itemInfo
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func connectGetInfomation(_ type: NewsType, completion: @escaping ([InformationModel]) -> (Void)) {
        print("\(TAG) - \(#function) - \(#line) - type : \(type.rawValue)")
        self.dbFireStore.collection(OrderFolderName.rootNews.rawValue).order(by: "time", descending: true).whereField("type", isEqualTo: type.rawValue).whereField("isEnable", isEqualTo: true).limit(to: 3).getDocuments { [weak self](snapshot, error) in
            var arrInfo = [InformationModel]()
            if let documents = snapshot?.documents {
                let decoder = JSONDecoder()
                documents.forEach { (document) in
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                        var result = try decoder.decode(InformationModel.self, from: data)
                        if type == .news {
                            result.colorStart = Tools.hexStringToUIColor(hex: "#BD3A52")
                            result.colorEnd = Tools.hexStringToUIColor(hex: "#FED182")
                        } else {
                            result.colorStart = Tools.hexStringToUIColor(hex: "#3D73C5")
                            result.colorEnd = Tools.hexStringToUIColor(hex: "#4C9F95")
                        }
                        arrInfo.append(result)
                    } catch  {
                        print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    }
                }
            }
            completion(arrInfo)
        }
    }

}

extension InfomationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrInfomation.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 320
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupportMainCell", for: indexPath) as! SupportMainCell
        cell.typeShow = 3
        cell.loadingView.stopAnimating()
        cell.viewLoading.isHidden = true
        let items = arrInfomation[indexPath.section]
        cell.arrInfo = items
        return cell
    }
}
