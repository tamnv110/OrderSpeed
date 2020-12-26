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
    var arrProductReal = [ProductModel]()
    var isShowToast = false
    var toast: ToastView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        createTableHeader()
        
        tbHome.tableFooterView = UIView(frame: .zero)
        tbHome.register(UINib(nibName: "BankInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BankInfoTableViewCell")
        tbHome.register(UINib(nibName: "NEWSTableViewCell", bundle: nil), forCellReuseIdentifier: "NEWSTableViewCell")
        tbHome.register(UINib(nibName: "SupportMainCell", bundle: nil), forCellReuseIdentifier: "SupportMainCell")
        tbHome.register(UINib(nibName: "ProductTMDTTableCell", bundle: nil), forCellReuseIdentifier: "ProductTMDTTableCell")

        let isLegal = (Tools.getObjectFromDefault("KEY_LEGAL") as? Bool) ?? false
        if isLegal {
            connectGetNotificationPopup()
        } else {
            DispatchQueue.main.async {
                let vc = LegalViewController(nibName: "LegalViewController", bundle: nil)
                vc.modalPresentationStyle = .overFullScreen
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_CHOOSE_STORE"), object: nil, queue: .main) { (notification) in
            if let item = notification.object as? ProductSiteModel {
                if item.sort == -110 {
                    if Tools.NDT_LABEL.isEmpty {
                        self.showErrorAlertView("Chức năng chưa sẵn sàng hoặc đã bị vô hiệu.") {
                            
                        }
                    } else {
                        DispatchQueue.main.async {
                            let vc = CreateOrderViewController(nibName: "CreateOrderViewController", bundle: nil)
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                } else {
                    self.showSFSafariController(item.link)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_COPY_BANK_NUMBER"), object: nil, queue: .main) { (notification) in
            print("\(self.TAG) - \(#function) - \(#line) - copy thanh cong")
            if !self.isShowToast {
                self.isShowToast = true
                if self.toast == nil {
                    self.toast = ToastView()
                }
                self.toast?.showMessage("Đã sao chép", inView: self.view)
                if #available(iOS 10.0, *) {
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
                        self.isShowToast = false
                        self.toast?.removeFromSuperview()
                    }
                } else {
                    Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.eventTimerSchedule(_:)), userInfo: nil, repeats: false)
                }
            }
            
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_MAKE_PHONE_CALL"), object: nil, queue: .main) { (notification) in
            if let phonenumber = notification.object as? String {
                Tools.makePhoneCall(phonenumber)
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_MAKE_MESSENGER"), object: nil, queue: .main) { (notification) in
            if let messenger = notification.object as? String {
                print("\(#file) - \(#line) - messenger : \(messenger)")
                Tools.openMessengerApp(messenger)
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_CREATE_WITH_LINK"), object: nil, queue: .main) { [weak self](notification) in
            if let url = notification.object as? String {
                print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - url : \(url)")
                DispatchQueue.main.async {
                    let vc = CreateOrderViewController(nibName: "CreateOrderViewController", bundle: nil)
                    vc.hidesBottomBarWhenPushed = true
                    vc.urlInput = url
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("CLICK_PRODUCT_REAL"), object: nil, queue: .main) { [weak self](notification) in
            if let item = notification.object as? ProductModel {
                DispatchQueue.main.async {
                    let vc = DetailProductViewController(nibName: "DetailProductViewController", bundle: nil)
                    vc.hidesBottomBarWhenPushed = true
                    vc.itemProduct = item
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_NDT_LABEL"), object: nil, queue: nil) { (notification) in
            if Tools.NDT_LABEL.isEmpty {
                self.connectGetProductOS()
            }
            self.connectGetProductSite()
        }
        
        self.showProgressHUD("Lấy dữ liệu...")
        connectGetLabel()
        connectGetBank {
            self.completionRequest.0 = true
        }
        connectGetSupport {
            self.completionRequest.1 = true
        }
        connectGetInfomation(.news) {
            self.completionRequest.2 = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showAlertController(.showSuccess, message: "123456", title: "")
        }
    }
    
    func connectGetLabel() {
        self.dbFireStore.collection(OrderFolderName.settings.rawValue).document("LabelCurrency").getDocument { (snapshot, error) in
            if let document = snapshot?.data() {
                if let tiGia = document["value"] as? String, let sOnVer = document["version"] as? String, let dOnVer = Double(sOnVer) {
                    if let apVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let dApVer = Double(apVer) {
                        if dApVer <= dOnVer {
                            Tools.NDT_LABEL = tiGia
                        } else {
                            Tools.NDT_LABEL = ""
                        }
                    } else {
                        Tools.NDT_LABEL = tiGia
                    }
                    NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_NDT_LABEL"), object: nil, userInfo: nil)
                }
            }
        }
    }

    @objc func eventTimerSchedule(_ timer: Timer) {
        self.toast?.removeFromSuperview()
        timer.invalidate()
    }
    
    func showSFSafariController(_ link: String) {
        if link.hasPrefix("http") {
            let vc = CustomBrowserViewController(nibName: "CustomBrowserViewController", bundle: nil)
            vc.arrURL.append(link)
            vc.hidesBottomBarWhenPushed = true
            self.present(vc, animated: true, completion: nil)
        } else {
            let vc = ListProductViewController(nibName: "ListProductViewController", bundle: nil)
            vc.idsDoc = link
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = ""
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
    
    func connectGetProductOS() {
        self.dbFireStore.collection(OrderFolderName.rootProductReal.rawValue).limit(to: 8).getDocuments { [weak self](snapshot, error) in
            if let documents = snapshot?.documents {
                var arrProductOS = [ProductModel]()
                for document in documents {
                    let dict = document.data()
                    var item = ProductModel(code: "1", link: dict["link"] as! String, name: dict["name"] as! String, option: "", amount: 0, price: (dict["price"] as? Double) ?? 0, fee: 0, status: "", note: "")
                    item.images = [String]()
                    item.images?.append((dict["thumbnail"] as? String) ?? "")
                    item.code = document.documentID
                    item.option = (dict["detail"] as? String) ?? ""
                    arrProductOS.append(item)
                }
                if arrProductOS.count > 0 {
                    self?.arrProductReal.append(contentsOf: arrProductOS)
                    self?.reloadWhenDone()
                }
            }
        }
    }
    
    func reloadWhenDone() {
        if completionRequest.0 && completionRequest.1 && completionRequest.2 {
            DispatchQueue.main.async {
                self.tbHome.reloadData()
            }
        }
    }
    
    func connectGetProductSite() {
        var typeShow = 0
        if Tools.NDT_LABEL.isEmpty {
            typeShow = 1
        }
        self.dbFireStore.collection(OrderFolderName.rootProductSite.rawValue).order(by: "sort", descending: false).whereField("type_show", isEqualTo: typeShow).getDocuments { [weak self](snapshot, error) in
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
                        header.arrSite.removeAll()
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
//            .whereField("isEnable", isEqualTo: true).whereField("isPopUp", isEqualTo: false)
        self.dbFireStore.collection(OrderFolderName.rootNews.rawValue).order(by: "time", descending: true).whereField("type", isEqualTo: type.rawValue).whereField("isPopUp", isEqualTo: false).whereField("isEnable", isEqualTo: true).limit(to: 1).getDocuments { [weak self](snapshot, error) in
            if let document = snapshot?.documents.first {
                let decoder = JSONDecoder()
                do {
                    let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                    let result = try decoder.decode(InformationModel.self, from: data)
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
    
    func connectGetNotificationPopup() {
        self.dbFireStore.collection(OrderFolderName.rootNews.rawValue).whereField("type", isEqualTo: NewsType.notification.rawValue).whereField("isEnable", isEqualTo: true).whereField("isPopUp", isEqualTo: true).order(by: "time", descending: true).limit(to: 1).getDocuments { [weak self](snapshot, error) in
            if let document = snapshot?.documents.first {
                let decoder = JSONDecoder()
                do {
                    let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                    let result = try decoder.decode(InformationModel.self, from: data)
                    print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - result : \(result.title)")
                    self?.showAlertController(.showContent, message: result.desc ?? result.content, title: result.title)
                } catch  {
                    print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc func eventChooseSearch(_ sender: UIBarButtonItem) {
//        let vc = ChooseCityViewController(nibName: "ChooseCityViewController", bundle: nil)
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func eventChooseNotification(_ sender: UIBarButtonItem) {
        self.navigationItem.title = "Thông báo"
        let vc = NotificationViewController(nibName: "NotificationViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
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
        return (completionRequest.0 && completionRequest.1 && completionRequest.2) ? 4 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 || section == 3 {
            return 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let wCol = UIScreen.main.bounds.width / 2 - 8
            let hCol = wCol * 1.54
            let hCell = hCol * CGFloat(arrProductReal.count / 2)
            return hCell
        }
        else if indexPath.section == 1 {
            return itemInfo != nil ? UITableView.automaticDimension : 0
        }
        else if indexPath.section == 2 {
            return 390.0
        } else if indexPath.section == 3 {
            return 270.0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 && section != 1 {
            return 60
        } else if section == 0 && arrProductReal.count > 0 {
            return 50
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 && section != 1 {
            let header = HomeHeaderSectionView.instanceFromNib()
            header.lblTitle.text = (section == 2) ? "ngân hàng".uppercased() : "hỗ trợ".uppercased()
            return header
        } else if section == 0 && arrProductReal.count > 0 {
            let header = UIView()
            header.backgroundColor = .clear
            let lblTitle = UILabel()
            lblTitle.translatesAutoresizingMaskIntoConstraints = false
            header.addSubview(lblTitle)
            lblTitle.text = "TOP sản phẩm".uppercased()
            lblTitle.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            lblTitle.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16).isActive = true
            lblTitle.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
            
            let btnShowMore = UIButton()
            btnShowMore.backgroundColor = .clear
            btnShowMore.translatesAutoresizingMaskIntoConstraints = false
            header.addSubview(btnShowMore)
            btnShowMore.setTitle("Xem thêm", for: .normal)
            btnShowMore.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            btnShowMore.setTitleColor(.black, for: .normal)
            btnShowMore.heightAnchor.constraint(equalToConstant: 40).isActive = true
            btnShowMore.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -8).isActive = true
            btnShowMore.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
            
            btnShowMore.addTarget(self, action: #selector(eventChooseShowMore(_:)), for: .touchUpInside)
            return header
        }
        return nil
    }
    
    @objc func eventChooseShowMore(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = ListProductViewController(nibName: "ListProductViewController", bundle: nil)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SupportMainCell {
            if indexPath.section == 2 {
                arrBank == nil ? cell.loadingView.startAnimating() : cell.loadingView.stopAnimating()
            } else {
                arrSupport == nil ? cell.loadingView.startAnimating() : cell.loadingView.stopAnimating()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SupportMainCell {
            if (indexPath.section == 2 && arrBank == nil) || (indexPath.section == 3 && arrSupport == nil) {
                cell.loadingView.stopAnimating()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTMDTTableCell", for: indexPath) as! ProductTMDTTableCell
            cell.arrProduct = arrProductReal
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NEWSTableViewCell", for: indexPath) as! NEWSTableViewCell
            if let _itemInfo = itemInfo {
                cell.showInfo(_itemInfo)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupportMainCell", for: indexPath) as! SupportMainCell
            if indexPath.section == 2 {
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
        if indexPath.section == 1 {
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
