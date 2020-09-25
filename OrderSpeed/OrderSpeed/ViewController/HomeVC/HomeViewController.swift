//
//  HomeViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/4/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import SafariServices

extension UITableView {
    func updateHeightHeader() {
        if let headerView = self.tableHeaderView {
            var headerFrame = headerView.frame
            let newHeight = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            if newHeight != headerFrame.height {
                headerFrame.size.height = newHeight
                headerView.frame = headerFrame
                self.tableHeaderView = headerView
            }
        }
    }
}

class HomeViewController: MainViewController {

    @IBOutlet weak var tbHome: UITableView!
    
    var arrBank: [BankInfoModel]?
    var arrSupport: [SupportModel]?
    var itemInfo: InformationModel?
    var completionRequest = (false, false, false) {
        didSet {
            if completionRequest.0 && completionRequest.1 && completionRequest.2 {
                self.hideProgressHUD()
                DispatchQueue.main.async {
                    self.tbHome.reloadData()
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ""
        setupNavigationBar()
        createTableHeader()
        
        tbHome.tableFooterView = UIView(frame: .zero)
        tbHome.register(UINib(nibName: "BankInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BankInfoTableViewCell")
        tbHome.register(UINib(nibName: "NEWSTableViewCell", bundle: nil), forCellReuseIdentifier: "NEWSTableViewCell")
        tbHome.register(UINib(nibName: "SupportMainCell", bundle: nil), forCellReuseIdentifier: "SupportMainCell")
        
        if let window = self.appDelegate.window {
            let tempView = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
            tempView.backgroundColor = UIColor.red
            window.addSubview(tempView)
        }
        
        self.showProgressHUD("Lấy dữ liệu...")
        connectGetProductSite()
        connectGetBank {
            self.completionRequest.0 = true
        }
        connectGetSupport {
            self.completionRequest.1 = true
        }
        connectGetInfomation(.news) {
            self.completionRequest.2 = true
        }
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_CHOOSE_STORE"), object: nil, queue: .main) { (notification) in
            if let item = notification.object as? ProductSiteModel {
                if item.sort == -110 {
                    DispatchQueue.main.async {
                        let vc = CreateOrderViewController(nibName: "CreateOrderViewController", bundle: nil)
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    self.showSFSafariController(item.link)
                }
            }
        }
    }
    
    func showSFSafariController(_ link: String) {
        guard let url = URL(string: link) else { return }
        let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
        self.present(vc, animated: true, completion: nil)
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true

    }
    
    func setupNavigationBar() {
        let btnLeft = UIBarButtonItem(image: UIImage(named: "logo_home"), style: .done, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = btnLeft
        
        let btnNotification = UIBarButtonItem(image: UIImage(named: "icon_notification"), style: .done, target: self, action: #selector(eventChooseNotification(_:)))
        self.navigationItem.rightBarButtonItem = btnNotification
    }
    
    func createTableHeader() {
        let header = HomeHeaderView.instanceFromNib()
        header.frame = CGRect(x: 0, y: 0, width: tbHome.frame.width, height: 316)
        tbHome.tableHeaderView = header
        header.tfSearch.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let headerView = tbHome.tableHeaderView as? HomeHeaderView {
            var headerFrame = headerView.frame
            let newHeight = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            if newHeight != headerFrame.height {
                headerFrame.size.height = newHeight
                headerView.frame = headerFrame
                tbHome.tableHeaderView = headerView
            }
        }
    }
    
    func connectGetProductSite() {
        self.dbFireStore.collection(OrderFolderName.rootProductSite.rawValue).order(by: "sort", descending: false).getDocuments { [weak self](snapshot, error) in
            if let documents = snapshot?.documents {
                let decoder = JSONDecoder()
                var arrProductSite = [ProductSiteModel]()
                for document in documents {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                        let result = try decoder.decode(ProductSiteModel.self, from: data)
                        arrProductSite.append(result)
                    } catch  {
                        print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    }
                }
                if arrProductSite.count > 0 {
                    if let header = self?.tbHome.tableHeaderView as? HomeHeaderView {
                        header.arrSite.append(contentsOf: arrProductSite)
                    }
                }
            }
        }
    }
    
    func connectGetBank(completion: @escaping () -> ()) {
        self.dbFireStore.collection(OrderFolderName.rootBank.rawValue).limit(to: 6).order(by: "sort", descending: false).getDocuments { [weak self](snapshot, error) in
            if let documents = snapshot?.documents {
                let decoder = JSONDecoder()
                for document in documents {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                        let result = try decoder.decode(BankInfoModel.self, from: data)
                        if self?.arrBank == nil {
                            self?.arrBank = [BankInfoModel]()
                        }
                        self?.arrBank?.append(result)
                    } catch  {
                        print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    }
                }
               
            } else {
                if self?.arrBank == nil {
                    self?.arrBank = [BankInfoModel]()
                }
            }
            completion()
        }
    }
    
    func connectGetSupport(completion: @escaping () -> ()) {
        self.dbFireStore.collection(OrderFolderName.rootSupport.rawValue).limit(to: 9).getDocuments { [weak self](snapshot, error) in
            if let documents = snapshot?.documents {
                let decoder = JSONDecoder()
                for document in documents {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                        let result = try decoder.decode(SupportModel.self, from: data)
                        if self?.arrSupport == nil {
                            self?.arrSupport = [SupportModel]()
                        }
                        self?.arrSupport?.append(result)
                    } catch  {
                        print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    }
                }
            } else {
                if self?.arrSupport == nil {
                    self?.arrSupport = [SupportModel]()
                }
            }
            completion()
        }
    }
    
    func connectGetInfomation(_ type: NewsType, completion: @escaping () -> ()) {
        print("\(TAG) - \(#function) - \(#line) - type : \(type.rawValue)")
        self.dbFireStore.collection(OrderFolderName.rootNews.rawValue).order(by: "time", descending: true).whereField("type", isEqualTo: type.rawValue).whereField("isEnable", isEqualTo: true).limit(to: 1).getDocuments { [weak self](snapshot, error) in
            if let document = snapshot?.documents.first {
                let decoder = JSONDecoder()
                do {
                    let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                    var result = try decoder.decode(InformationModel.self, from: data)
                    if self?.itemInfo == nil {
                        self?.itemInfo = result
                        
                    }
                } catch  {
                    print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                }
            }
            completion()
        }
    }
    
    
    @objc func eventChooseSearch(_ sender: UIBarButtonItem) {
//        let vc = ChooseCityViewController(nibName: "ChooseCityViewController", bundle: nil)
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func eventChooseNotification(_ sender: UIBarButtonItem) {
        
    }
    
    func searchOrderWithCode(_ orderCode: String) {
        self.showProgressHUD("Tìm đơn...")
        let orderCol = self.dbFireStore.collection(OrderFolderName.rootOrderProduct.rawValue)
        orderCol.whereField("code", isEqualTo: orderCode).limit(to: 1).getDocuments { [weak self](snapshot, error) in
            self?.hideProgressHUD()
            if let error = error {
                print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                self?.showErrorAlertView("Có lỗi xảy ra, vui lòng thử lại sau.", completion: {})
            } else if let documents = snapshot?.documents {
                if documents.count == 0 {
                    self?.showAlertView("Không tìm thấy đơn hàng với mã đơn: \(orderCode)", completion: {})
                } else if let document = documents.first {
                    print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - documents.count : \(documents.count)")
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                        var result = try JSONDecoder().decode(OrderProductDataModel.self, from: data)
                        result.idOrder = document.documentID
                        self?.openOrderSearch(result)
                    } catch  {
                        print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func openOrderSearch(_ order: OrderProductDataModel) {
        DispatchQueue.main.async {
            let vc = StatusOrderViewController(nibName: "StatusOrderViewController", bundle: nil)
            vc.orderProduct = order
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let sSearch = textField.text, !sSearch.trimmingCharacters(in: .whitespaces).isEmpty {
            searchOrderWithCode(sSearch)
        }
        return true
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (completionRequest.0 && completionRequest.1 && completionRequest.2) ? 3 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 || section == 2 {
            return 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return itemInfo != nil ? UITableView.automaticDimension : 0
        }
        else if indexPath.section == 1 {
            return 390.0
        } else if indexPath.section == 2 {
            return 270.0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 60
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let header = HomeHeaderSectionView.instanceFromNib()
            header.lblTitle.text = (section == 1) ? "ngân hàng".uppercased() : "hỗ trợ".uppercased()
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SupportMainCell {
            if indexPath.section == 1 {
                arrBank == nil ? cell.loadingView.startAnimating() : cell.loadingView.stopAnimating()
            } else {
                arrSupport == nil ? cell.loadingView.startAnimating() : cell.loadingView.stopAnimating()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SupportMainCell {
            if (indexPath.section == 1 && arrBank == nil) || (indexPath.section == 2 && arrSupport == nil) {
                cell.loadingView.stopAnimating()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NEWSTableViewCell", for: indexPath) as! NEWSTableViewCell
            if let _itemInfo = itemInfo {
                cell.showInfo(_itemInfo)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupportMainCell", for: indexPath) as! SupportMainCell
            if indexPath.section == 1 {
                cell.typeShow = 1
                if arrBank != nil {
                    cell.viewLoading.isHidden = true
                } else {
                    cell.viewLoading.isHidden = false
                }
                cell.arrInfo = arrBank
            } else {
                cell.typeShow = 0
                if arrSupport != nil {
                    cell.viewLoading.isHidden = true
                } else {
                    cell.viewLoading.isHidden = false
                }
                cell.arrInfo = arrSupport
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let _itemInfo = itemInfo {
                DispatchQueue.main.async {
                    let vc = DetailInfomationViewController(nibName: "DetailInfomationViewController", bundle: nil)
                    vc.infomation = _itemInfo
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
}
